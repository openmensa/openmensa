# frozen_string_literal: true

class FeedChanged < Message
  validates :kind, inclusion: {
    in: %i[created updated deleted]
  }

  def kind
    data[:kind]
  end

  def kind=(value)
    data[:kind] = value
  end

  def name
    data[:name]
  end

  def name=(name)
    data[:name] = name
  end

  def to_html
    I18n.t("messages.html.feed_updated.#{kind}", **data)
  end

  def to_text_mail
    I18n.t("messages.text_mail.feed_updated.#{kind}", **data)
  end

  def to_json(*_args)
    {
      "type" => self.class.name.underscore,
      "kind" => kind,
      "name" => name
    }
  end
end
