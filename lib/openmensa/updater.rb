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

  # very bad, needs improvement; but know at the moment no better way
  def xfp(object, expression)
    object.find('om:' + expression,
        'om:http://openmensa.org/open-mensa-v' + @version.to_s).empty?
  end

  def xff(object, expression)
    object.find_first('om:' + expression,
        'om:http://openmensa.org/open-mensa-v' + @version.to_s)
  end

  def xfe(object, expression, &block)
    object.find('om:' + expression,
        'om:http://openmensa.org/open-mensa-v' + @version.to_s).each &block
  end


  def addMeal(day, category, meal)
    day.meals.create(
      category: category,
      name: xff(meal, 'name').content
    )
    @changed = true
  end

  def updateMeal(meal, category, mealData)
    # at the moment no action needed
  end

  def addDay(dayData)
    day = canteen.days.create(date: Date.parse(dayData['date']))
    if xfp dayData, 'closed'
      xfe dayData, 'category' do |category|
        xfe category, 'meal' do |meal|
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
    if not xfp dayData, 'closed'
      @changed = !day.closed?
      day.meals.destroy_all
      day.update_attribute :closed, true
    else
      if day.closed?
        day.update_attribute :closed, false
        @changed = true
      end
      names = day.meals.inject({}) { |m,v| m[v.name.to_s] = v; m }
      xfe dayData, 'category' do |category|
        xfe category, 'meal' do |meal|
          name = xff(meal, 'name').content
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
    xfe canteenData, 'day' do |day|
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
