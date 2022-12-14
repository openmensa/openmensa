# frozen_string_literal: true

class MessageDecorator < Draper::Decorator
  def icon_class
    return "" if model.nil?

    if model.created_at < 7.days.ago
      "icon-ok"
    elsif model.created_at < 2.days.ago
      "icon-warning-sign"
    else
      "icon-bolt"
    end
  end

  def created_at
    return "" if model.nil?

    helpers.l model.created_at, format: :short
  end
end
