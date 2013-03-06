require 'open-uri'
require_dependency 'message'

class OpenMensa::Updater
  include Nokogiri
  attr_reader :canteen, :document, :version, :data, :reader

  def initialize(canteen, version = nil)
    @canteen = canteen
    @version = version
  end

  # 1. Fetch feed data
  def fetch!
    @data = OpenMensa::FeedLoader.new(canteen).load!
  rescue OpenMensa::FeedLoader::FeedLoadError => error
    error.cause.tap do |err|
      case err
        when URI::InvalidURIError
          Rails.logger.warn "Invalid URI (#{canteen.url}) in canteen #{canteen.id}"
          FeedInvalidUrlError.create canteen: canteen
        when OpenURI::HTTPError
          create_fetch_error! err.message, err.message.to_i
        else
          create_fetch_error! err.message
      end
    end
    false
  end

  # 2. Parse XML data
  def parse!
    @version  = nil
    @document = OpenMensa::FeedParser.new(data).parse!
  rescue OpenMensa::FeedParser::ParserError => err
    err.errors.each do |error|
      create_validation_error! :no_xml, error.message
    end
    false
  end

  # 2. Validate XML document
  def validate!
    OpenMensa::FeedValidator.new(document).tap do |validator|
      @version = validator.version
      validator.validate!
    end
    version
  rescue OpenMensa::FeedValidator::InvalidFeedVersionError
    create_validation_error! :unknown_version
    false
  rescue OpenMensa::FeedValidator::FeedValidationError => err
    err.errors.each do |error|
      create_validation_error! :invalid_xml, error.message
    end
    false
  end


  # 3. Process data

  # Returns true if any change was applied.
  +Transactional
  def update_canteen!
    reader.days(reader.canteens.first).inject(false) do |changed, day|
      update_day(day, canteen.days.where(date: day.date.to_s).first || canteen.days.create!(date: day.date.to_s)) || changed
    end
  end

  # Returns true if any change was applied.
  def update_day(node, day)
    if node.closed
      close_day day
    else
      changed = update_meals(node, day)
      day.closed? ? open_day(day) : changed
    end
  end

  # Returns true if any change was applied.
  def close_day(day)
    return false if day.closed?

    day.meals.destroy_all
    day.update_attribute :closed, true
  end

  # Returns true if any change was applied.
  def open_day(day)
    return false unless day.closed?

    day.update_attribute :closed, false
  end

  # Returns true if any change was applied.
  def update_meals(node, day) # day, day_data
    nodes = reader.meals(node)

    nodes.inject(delete_old_meals(day, nodes)) do |changed, node|
      update_meal(node, day.meals.select{ |m| node.matches? m }.first || day.meals.new) || changed
    end
  end

  # Returns true if any change was applied.
  def delete_old_meals(day, nodes)
    day.meals.inject(false) do |changed, meal|
      meal.destroy and next true unless nodes.any? { |node| node.matches? meal }
      changed
    end
  end

  # Returns true if any change was applied.
  def update_meal(node, meal)
    meal.category = node.category
    meal.name     = node.name
    meal.prices   = node.prices
    meal.notes    = node.notes

    if meal.changed? or meal.new_record?
      meal.save!
    else
      false
    end
  end

  # All together
  #
  # Returns true if any change was applied.
  def update!
    return false unless fetch! and parse! and validate!

    @reader = OpenMensa::FeedReader.new(document, version)
    update_canteen!.tap do
      canteen.update_column :last_fetched_at, Time.zone.now
    end
  end

private
  def create_validation_error!(kind, message = nil)
    FeedValidationError.create! canteen: canteen,
                                version: version,
                                message: message,
                                kind: kind
  end

  def create_fetch_error!(message, code = nil)
    FeedFetchError.create canteen: canteen,
                          message: message,
                          code: code
  end
end
