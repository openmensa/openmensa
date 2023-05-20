# frozen_string_literal: true

class FeedFetchError < Message
  def code
    data[:code]
  end

  def code=(value)
    data[:code] = value
  end

  def message
    data[:message]
  end

  def message=(value)
    data[:message] = value
  end

  def to_json(*_args)
    {
      "type" => self.class.name.underscore,
      "code" => code,
      "message" => message
    }
  end
end
