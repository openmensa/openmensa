module OpenMensa

  # The FeedReader can read data from a parsed and validated XML document.
  #
  class FeedReader
    attr_reader :document, :version

    # An UnsupportedVersionError will be raised when
    # a feature is going to be red but is nut supported by
    # specified document schema version.
    class UnsupportedVersionError < StandardError; end

    class CanteenNode < Struct.new(:node); end
    class DayNode < Struct.new(:date, :closed, :node); end
    class MealNode < Struct.new(:category, :name, :prices, :notes, :node)
      def matches?(node)
        node.category == category and node.name == name
      end
    end

    def initialize(document, version)
      @document = document
      @version  = version
    end

    def canteens
      case version
        when 1
          [ CanteenNode.new(document.root) ]
        when 2
          node = document.root.children.first
          node = node.next while node.name != 'canteen'
          node.nil? ? [] : [ CanteenNode.new(node) ]
        else
          raise UnsupportedVersionError.new
      end
    end

    def days(canteen)
      canteen.node.element_children.map do |xml|
        read_day xml
      end
    end

    def meals(day)
      day.node.element_children.inject([]) do |all_meals, category_xml|
        category = category_xml['name']
        category_xml.element_children.inject(all_meals) do |meals, meal_xml|
          meal = read_meal category, meal_xml
          meals << meal if meal
          meals
        end if category
      end.uniq { |meal| [ meal.category, meal.name ] }
    end

  private
    def read_day(xml)
      DayNode.new(
          Date.parse(xml['date']),
          xml.children.any? { |node| node.name == 'closed' },
          xml
      )
    end

    def read_meal(category, xml)
      name   = xml.children.find { |node| node.name == 'name' }.content
      prices = read_prices xml
      notes  = read_notes xml

      return nil unless name and prices and notes

      MealNode.new(category, name, prices, notes, xml)
    end

    def read_prices(xml)
      xml.children.inject({student: nil, employee: nil, pupil: nil, other: nil}) do |prices, node|
        prices[node['role']] = node.content if node.name == 'price' and version == 2
        prices
      end
    end

    def read_notes(xml)
      xml.element_children.select { |n| n.name == 'note' }.map(&:content)
    end
  end
end
