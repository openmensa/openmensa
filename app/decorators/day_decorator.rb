# frozen_string_literal: true

class DayDecorator < Draper::Decorator
  include ApiResponder::Formattable

  decorates :day

  def as_ics_event
    Icalendar::Event.new.tap do |event|
      event.uid = model.id.to_s
      event.dtstart = Icalendar::Values::Date.new(model.date)
      event.dtend = Icalendar::Values::Date.new(model.date)
      event.summary = ics_summary
      event.description = ics_description
    end
  end

  def as_api_v2(options)
    result = {
      date: model.date.iso8601,
      closed: model.closed,
    }
    result[:meals] = MealDecorator.decorate_collection(model.meals) if options[:include].try(:include?, :meals)
    result
  end

  private

  def ics_summary
    model.canteen.name
  end

  def ics_description
    StringIO.new.tap do |io|
      model.meals.group_by(&:category).each do |category, meals|
        io << "#{category}:\n" if category.present?
        meals.each do |meal|
          io << "- #{meal.name}"
          if meal.prices.any?
            io << " ("
            io << meal.prices.map {|_, price| h.number_to_currency(price, uni: "€") }.join(", ")
            io << ")"
          end
          io << "\n"
          next unless (notes = meal.notes.to_a).any?

          notes.each do |note|
            io << "  * #{note.name}\n"
          end
        end
        io << "\n"
      end
    end.string
  end
end
