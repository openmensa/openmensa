# frozen_string_literal: true

class FeedFetchError < Message
  def code
    payload[:code]
  end

  def code=(value)
    payload[:code] = value
  end

  def message
    payload[:message]
  end

  def message=(value)
    payload[:message] = value
  end

  def to_json(*_args)
    {
      "type" => self.class.name.underscore,
      "code" => code,
      "message" => message,
    }
  end
end
