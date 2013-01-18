class DayDecorator < Draper::Decorator
  include ApiDecorator
  decorates :day
  decorates_association :meals

  def to_version_2(options)
    result = {
      date: model.date.iso8601,
      closed: model.closed
    }
    result[:meals] = meals if options[:include].try(:include?, :meals)
    result
  end
end
