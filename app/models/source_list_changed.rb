# frozen_string_literal: true

class SourceListChanged < Message
  validates :kind, inclusion: {
    in: %i[new_source source_archived source_reactivated]
  }

  def kind
    data[:kind]
  end

  def kind=(m)
    data[:kind] = m
  end

  def name
    data[:name]
  end

  def name=(name)
    data[:name] = name
  end

  def url
    data[:url]
  end

  def url=(url)
    data[:url] = url
  end

  def to_html
    I18n.t("messages.html.source_list_changed.#{kind}", data)
  end

  def to_text_mail
    I18n.t("messages.text_mail.source_list_changed.#{kind}", data)
  end

  def to_json(*_args)
    {
      "type" => self.class.name.underscore,
      "kind" => kind,
      "name" => name,
      "url" => url
    }
  end
end
