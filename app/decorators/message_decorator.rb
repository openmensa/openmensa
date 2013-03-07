class MessageDecorator < Draper::Decorator
  def icon_class
    return '' if model.nil?
    if model.created_at < Time.zone.now - 7.days
      'icon-ok'
    elsif model.created_at < Time.zone.now - 2.days
      'icon-warning-sign'
    else
      'icon-bolt'
    end
  end

  def created_at
    return '' if model.nil?
    helpers.l model.created_at, format: :short
  end
end
