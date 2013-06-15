class DayDecorator < Draper::Decorator
  include ApiResponder::Formattable
  decorates :day

  def as_api_v2(options)
    result = {
      date: model.date.iso8601,
      closed: model.closed
    }
    result[:meals] = model.meals.order(:pos).decorate if options[:include].try(:include?, :meals)
    result
  end
end
