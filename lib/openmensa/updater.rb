require 'libxml'
class OpenMensa::Updater
  include LibXML
  def initialize(canteen)
    @canteen = canteen
    @updated = false
  end
  def canteen
    @canteen
  end

  def self.schema_v1
    @schema_v1 ||= XML::Schema.new Rails.root.join('public', 'open-mensa-v1.xsd').to_s
    @schema_v1
  end
  def self.schema_v2
    @schema_v2 ||= XML::Schema.new Rails.root.join('public', 'open-mensa-v2.xsd').to_s
    @schema_v2
  end

  def validate(data)
    @document = XML::Document.string data, options: XML::Parser::Options::NOERROR | XML::Parser::Options::NOWARNING | XML::Parser::Options::RECOVER
    begin
      result = @document.validate_schema(self.class.schema_v2)
      return 2
    rescue XML::Error
    end
    begin
      result = @document.validate_schema(self.class.schema_v1)
      return 1
    rescue XML::Error
    end
    false
  rescue XML::Error
    false
  end

  def addMeal(day, category, meal)
    day.meals.create(
      category: category,
      name: meal.find('name').first.content
    )
    @changed = true
  end

  def addDay(dayData)
    day = canteen.days.create(date: Date.parse(dayData['date']))
    dayData.find('category').each do |category|
      category.find('meal').each do |meal|
        addMeal(day, category['name'], meal)
      end
    end
    @changed = true
  end

  def changed?
    @changed
  end
end
