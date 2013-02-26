require 'open-uri'
require_dependency 'message'

class OpenMensa::Updater
  include Nokogiri
  attr_reader :canteen, :document, :version, :data

  def initialize(canteen, version = nil)
    @canteen = canteen
    @version = version
    @changed = false
  end

  def changed?
    @changed
  end

  # 1. Fetch feed data
  def fetch!
    @data = OpenMensa::FeedLoader.new(canteen).load!
  rescue OpenMensa::FeedLoader::FeedLoadError => error
    case error.cause
      when URI::InvalidURIError
        Rails.logger.warn "Invalid URI (#{canteen.url}) in canteen #{canteen.id}"
        FeedInvalidUrlError.create canteen: canteen
      when OpenURI::HTTPError
        FeedFetchError.create canteen: canteen,
                              code:    error.cause.message.to_i,
                              message: error.cause.message
      else
        FeedFetchError.create canteen: canteen,
                              code: nil,
                              message: error.message
    end
    false
  end

  # 2. Parse XML data
  def parse!
    @version  = nil
    @document = OpenMensa::FeedParser.new(data).parse!
  rescue OpenMensa::FeedParser::ParserError => err
    err.errors.each do |error|
      FeedValidationError.create canteen: canteen,
                                 version: version,
                                 kind: :no_xml,
                                 message: error.message
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
    FeedValidationError.create canteen: canteen,
                               version: nil,
                               kind: :unknown_version
    false
  rescue OpenMensa::FeedValidator::FeedValidationError => err
    err.errors.each do |error|
      FeedValidationError.create canteen: canteen,
                                 version: version,
                                 kind: :invalid_xml,
                                 message: error.message
    end
    false
  end


  # 3. process data
  def add_meal(day, category, meal)
    day.meals.create(
      category: category,
      name: meal.children.find { |node| node.name == 'name' }.content,
      prices: meal.children.inject({}) do |prices, node|
        prices[node['role']] = node.content if node.name == 'price' and @version == 2
        prices
      end,
      notes: meal.children.select { |n| n.name == 'note' }.map(&:content)
    )
    @changed = true
  end

  def update_meal(meal, category, meal_data)
    meal.prices = meal_data.children.inject({student: nil, employee: nil, pupil: nil, other: nil}) do |prices, node|
      prices[node['role']] = node.content if node.name == 'price' and @version == 2
      prices
    end
    meal.notes = meal_data.children.select { |n| n.name == 'note' }.map(&:content)
    meal.save if meal.changed?
  end

  def add_day(day_data)
    return if Date.parse(day_data['date']) < Date.today
    day = canteen.days.create(date: Date.parse(day_data['date']))
    if day_data.children.any? { |node| node.name == 'closed' }
      day.closed = true
      day.save!
    else
      day_data.children.select(&:element?).each do |category|
        category.children.select(&:element?).inject([]) do |names, meal|
          name = meal.children.find { |node| node.name == 'name' }.content
          unless names.include? name
            add_meal(day, category['name'], meal)
            names << name
          end
          names
        end
      end
    end
    @changed = true
  end

  def update_day(day, day_data)
    return if Date.parse(day_data['date']) < Date.today
    if day_data.children.any? { |node| node.name == 'closed' }
      @changed = !day.closed?
      day.meals.destroy_all
      day.update_attribute :closed, true
    else
      if day.closed?
        day.update_attribute :closed, false
        @changed = true
      end
      names = day.meals.inject({}) do |memo, value|
        memo[[value.category, value.name.to_s]] = value
        memo
      end
      day_data.children.select(&:element?).each do |category|
        category.children.select(&:element?).each do |meal|
          name = meal.children.find { |node| node.name == 'name' }.content
          meal_obj = names[[category['name'], name]]
          if meal_obj.is_a? Meal
            update_meal meal_obj, category['name'], meal
            names[[category['name'], name ]] = false
          elsif meal_obj.nil?
            add_meal day, category['name'], meal
          end
        end
      end
      names.keep_if { |key, meal| meal }
      if names.size > 0
        names.each_value { |meal| meal.destroy }
        @changed = true
      end
    end
  end


  def update_canteen(canteen_data)
    days = canteen.days.inject({}) { |m,v| m[v.date.to_s] = v; m }
    day_updated = nil
    canteen_data.children.select(&:element?).each do |day|
      canteen.transaction do
        date = day['date']
        if days.key? date
          update_day days[date], day
        else
          add_day day
        end
        day_updated = true
      end
    end
    if day_updated
      canteen.update_column :last_fetched_at, Time.zone.now
    end
    changed?
  end


  # all together
  def update
    return false unless fetch! and parse! and validate!

    canteen_data = case version
      when 1 then
        @document.root
      when 2 then
        node = @document.root.children.first
        while node.name != 'canteen'
          node = node.next
        end
        node
      else
        nil
    end
    update_canteen canteen_data
  end
end
