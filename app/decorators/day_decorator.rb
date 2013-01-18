class DayDecorator < Draper::Decorator
  include ApiDecorator
  decorates :day
  decorates_association :meals

  def to_version_2(options)
    {
      date: model.date.iso8601,
      closed: model.closed
    }
  end
end
