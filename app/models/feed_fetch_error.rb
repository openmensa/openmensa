# frozen_string_literal: true

class FeedFetchError < Message
  def code
    data[:code]
  end

  def code=(c)
    data[:code] = c
  end

  def message
    data[:message]
  end

  def message=(m)
    data[:message] = m
  end

  def to_json(*_args)
    {
      "type" => self.class.name.underscore,
      "code" => code,
      "message" => message
    }
  end
end
