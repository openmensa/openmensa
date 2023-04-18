# frozen_string_literal: true

class FeedValidationError < Message
  validates :kind, inclusion: {
    in: %i[no_xml no_json unknown_version invalid_xml invalid_json]
  }

  def version
    data[:version]
  end

  def version=(v)
    data[:version] = v
  end

  def kind
    data[:kind]
  end

  def kind=(m)
    data[:kind] = m
  end

  def message
    data[:message]
  end

  def message=(m)
    data[:message] = m
  end

  def to_html
    I18n.t("messages.html.feed_validation_error.#{kind}", **data)
  end

  def to_text_mail
    I18n.t("messages.text_mail.feed_validation_error.#{kind}", **data)
  end

  def to_json(*_args)
    {
      "type" => self.class.name.underscore,
      "kind" => kind,
      "version" => version,
      "message" => message
    }
  end
end
