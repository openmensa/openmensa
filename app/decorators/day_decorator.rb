class DayDecorator < Draper::Decorator
  include ApiResponder::Formattable
  decorates :day
  decorates_association :meals

  def as_api_v2(options)
    result = {
      date: model.date.iso8601,
      closed: model.closed
    }
    result[:meals] = meals if options[:include].try(:include?, :meals)
    result
  end
end
