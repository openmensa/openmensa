require 'open-uri'
require 'libxml'

class OpenMensa::Updater
  include LibXML
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
    false
  rescue OpenURI::HTTPRedirect => redirect
    if redirect.message.start_with? '301' # permanent redirect
      Rails.logger.warn "Update url of canteen #{canteen.id} to '#{redirect.uri.to_s}'"
      canteen.update_attribute :url, redirect.uri.to_s
    end
    fetch false
  end


  # 2. validate data
  def self.schema_v1
    @schema_v1 ||= XML::Schema.new Rails.root.join('public', 'open-mensa-v1.xsd').to_s
    @schema_v1
  end
  def self.schema_v2
    @schema_v2 ||= XML::Schema.new Rails.root.join('public', 'open-mensa-v2.xsd').to_s
    @schema_v2
  end

  def validate(data)
    XML::Error.set_handler { |e| }
    @document = XML::Document.string data, options: XML::Parser::Options::NOERROR | XML::Parser::Options::NOWARNING
    begin
      @document.validate_schema(self.class.schema_v2)
      return @version = 2
    rescue XML::Error
    end
    begin
      @document.validate_schema(self.class.schema_v1)
      return @version = 1
    rescue XML::Error
    end
    false
  rescue XML::Error
    false
  ensure
    XML::Error.reset_handler
  end


  # 3. process data
  def addMeal(day, category, meal)
    day.meals.create(
      category: category,
      name: meal.children.select { |node| node.name == 'name' }.first.content,
      prices: meal.children.inject({}) do |prices, node|
        prices[node['role']] = node.content if node.name == 'price'
        prices
      end
    )
    @changed = true
  end

  def updateMeal(meal, category, mealData)
    meal.prices = mealData.children.inject({student: nil, employee: nil, pupil: nil, other: nil}) do |prices, node|
      prices[node['role']] = node.content if node.name == 'price'
      prices
    end
    meal.save if meal.changed?
  end

  def addDay(dayData)
    day = canteen.days.create(date: Date.parse(dayData['date']))
    if dayData.children.select { |node| node.name == 'closed' }.empty?
      dayData.each_element do |category|
        category.each_element do |meal|
          addMeal(day, category['name'], meal)
        end
      end
    else
      day.closed = true
      day.save!
    end
    @changed = true
  end

  def updateDay(day, dayData)
    if not dayData.children.select { |node| node.name == 'closed' }.empty?
      @changed = !day.closed?
      day.meals.destroy_all
      day.update_attribute :closed, true
    else
      if day.closed?
        day.update_attribute :closed, false
        @changed = true
      end
      names = day.meals.inject({}) { |m,v| m[v.name.to_s] = v; m }
      dayData.each_element do |category|
        category.each_element do |meal|
          name = meal.children.select { |node| node.name == 'name' }.first.content
          if names.key? name
            updateMeal names[name], category['name'], meal
            names.delete name
          else
            addMeal day, category['name'], meal
          end
        end
      end
      if names.size > 0
        names.each_value { |meal| day.meals.delete meal }
        @changed = true
      end
    end
  end


  def updateCanteen(canteenData)
    days = canteen.days.inject({}) { |m,v| m[v.date.to_s] = v; m }
    canteenData.each_element do |day|
      date = day['date']
      if days.key? date
        updateDay days[date], day
      else
        addDay day
      end
    end
    if changed?
      canteen.update_column :last_fetched_at, Time.zone.now
    end
    changed?
  end


  # all togther
  def update
    document = fetch
    return false unless document
    version = validate document.read
    return false unless version
    canteenData = case version
      when 1 then @document.root
      when 2 then @document.root.children.first.next
    end
    updateCanteen canteenData
  end
end
