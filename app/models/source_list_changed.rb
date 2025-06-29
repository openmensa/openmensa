# frozen_string_literal: true

class SourceListChanged < Message
  validates :kind, inclusion: {
    in: %i[new_source source_archived source_reactivated],
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

  def url
    payload[:url]
  end

  def url=(url)
    payload[:url] = url
  end

  def to_html
    I18n.t("messages.html.source_list_changed.#{kind}", **payload)
  end

  def to_text_mail
    I18n.t("messages.text_mail.source_list_changed.#{kind}", **payload)
  end

  def to_json(*_args)
    {
      "type" => self.class.name.underscore,
      "kind" => kind,
      "name" => name,
      "url" => url,
    }
  end
end
