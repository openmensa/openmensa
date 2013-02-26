require 'open-uri'
require_dependency 'message'

class OpenMensa::Updater
  include Nokogiri
  def initialize(canteen, version=nil)
    @canteen = canteen
    @changed = false
    @version = version
    @document = nil
  end
  def canteen
    @canteen
  end

  def changed?
    @changed
  end

  def document
    @document
  end


  # 1. fetch data
  def fetch(handle_301=true)
    return false unless canteen.url.present?
    uri = URI.parse canteen.url
    open uri, redirect: !handle_301
  rescue URI::InvalidURIError
    Rails.logger.warn "Invalid URI (#{canteen.url}) in canteen #{canteen.id}"
    FeedInvalidUrlError.create canteen: canteen
    false
  rescue OpenURI::HTTPRedirect => redirect
    if redirect.message.start_with? '301' # permanent redirect
      Rails.logger.warn "Update url of canteen #{canteen.id} to '#{redirect.uri.to_s}'"
      FeedUrlUpdatedInfo.create canteen: canteen, old_url: canteen.url, new_url: redirect.uri.to_s
      canteen.update_attribute :url, redirect.uri.to_s
    end
    fetch false
  rescue OpenURI::HTTPError => error
    FeedFetchError.create({
        canteen: @canteen, code: error.message.to_i,
        message: error.message})
    false
  rescue => error
    FeedFetchError.create({
        canteen: @canteen, code: nil,
        message: error.message})
    false
  end


  # 2. validate data
  def self.schema_v1
    @schema_v1 ||= XML::Schema.new File.open(Rails.root.join('public', 'open-mensa-v1.xsd').to_s)
    @schema_v1
  end
  def self.schema_v2
    @schema_v2 ||= XML::Schema.new File.open(Rails.root.join('public', 'open-mensa-v2.xsd').to_s)
    @schema_v2
  end

  def validate(data)
    @version = nil
    @document = XML::Document.parse data
    @document.errors.each do |error|
      FeedValidationError.create({
        canteen: @canteen, version: @version,
        kind: :no_xml, message: error.message})
    end
    return false unless @document.errors.empty?

    @version = @document.root.nil? ? nil : @document.root[:version].to_i
    case @version
      when 1 then schema = self.class.schema_v1
      when 2 then schema = self.class.schema_v2
      else
        FeedValidationError.create({
          canteen: @canteen, version: nil,
          kind: :unknown_version })
        return false
    end

    errors = schema.validate(@document)
    errors.each do |error|
      FeedValidationError.create({
        canteen: @canteen, version: @version,
        kind: :invalid_xml, message: error.message })
    end
    return false unless errors.empty?
    @version
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
    document = fetch
    return false unless document
    version = validate document.read
    return false unless version

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
