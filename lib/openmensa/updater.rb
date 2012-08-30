require 'libxml'
class OpenMensa::Updater
  include LibXML
  def initialize(canteen)
    @canteen = canteen
    @changed = false
  end
  def canteen
    @canteen
  end

  def changed?
    @changed
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
    XML::Error.set_handler { |e| }
    @document = XML::Document.string data, options: XML::Parser::Options::NOERROR | XML::Parser::Options::NOWARNING
    begin
      @document.validate_schema(self.class.schema_v2)
      return 2
    rescue XML::Error
    end
    begin
      @document.validate_schema(self.class.schema_v1)
      return 1
    rescue XML::Error
    end
    false
  rescue XML::Error
    false
  ensure
    XML::Error.reset_handler
  end

  def addMeal(day, category, meal)
    day.meals.create(
      category: category,
      name: meal.find('name').first.content
    )
    @changed = true
  end

  def updateMeal(meal, category, mealData)
    # at the moment no action needed
  end


  def addDay(dayData)
    day = canteen.days.create(date: Date.parse(dayData['date']))
    if dayData.find('closed').empty?
      dayData.find('category').each do |category|
        category.find('meal').each do |meal|
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
    if not dayData.find('closed').empty?
      @changed = !day.closed?
      day.meals.destroy_all
      day.update_attribute :closed, true
    else
      if day.closed?
        day.update_attribute :closed, false
        @changed = true
      end
      names = day.meals.inject({}) { |m,v| m[v.name.to_s] = v; m }
      dayData.find('category').each do |category|
        category.find('meal').each do |meal|
          name = meal.find('name').first.content
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
    days = canteen.days.inject({}) { |m,v| m[v.date.to_s] = v }
    canteenData.find('day').each do |day|
      date = day['date']
      if days.key? date
        updateDay day
      else
        addDay day
      end
    end
  end
end
