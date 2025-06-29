# frozen_string_literal: true

class FeedChanged < Message
  validates :kind, inclusion: {
    in: %i[created updated deleted],
  }

  def kind
    payload[:kind]
  end

  def kind=(value)
    payload[:kind] = value
  end

  def name
    payload[:name]
  end

  def name=(name)
    payload[:name] = name
  end

  def to_html
    I18n.t("messages.html.feed_updated.#{kind}", **payload)
  end

  def to_text_mail
    I18n.t("messages.text_mail.feed_updated.#{kind}", **payload)
  end

  def to_json(*_args)
    {
      "type" => self.class.name.underscore,
      "kind" => kind,
      "name" => name,
    }
  end
end
