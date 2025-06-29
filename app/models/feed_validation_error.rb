# frozen_string_literal: true

class FeedValidationError < Message
  validates :kind, inclusion: {
    in: %i[no_xml no_json unknown_version invalid_xml invalid_json],
  }

  def version
    payload[:version]
  end

  def version=(value)
    payload[:version] = value
  end

  def kind
    payload[:kind]
  end

  def kind=(value)
    payload[:kind] = value
  end

  def message
    payload[:message]
  end

  def message=(value)
    payload[:message] = value
  end

  def to_html
    I18n.t("messages.html.feed_validation_error.#{kind}", **payload)
  end

  def to_text_mail
    I18n.t("messages.text_mail.feed_validation_error.#{kind}", **payload)
  end

  def to_json(*_args)
    {
      "type" => self.class.name.underscore,
      "kind" => kind,
      "version" => version,
      "message" => message,
    }
  end
end
