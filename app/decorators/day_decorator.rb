# frozen_string_literal: true

class DayDecorator < Draper::Decorator
  include ApiResponder::Formattable
  decorates :day

  def as_api_v2(options)
    result = {
      date: model.date.iso8601,
      closed: model.closed
    }
    if options[:include].try(:include?, :meals)
      result[:meals] = MealDecorator.decorate_collection(model.meals)
    end
    result
  end
end
