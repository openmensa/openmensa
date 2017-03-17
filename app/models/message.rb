class Message < ActiveRecord::Base
  belongs_to :messageable, polymorphic: true

  serialize :data, Hash

  validates :priority, inclusion: {
    in: %w(error warning info debug),
    message: I18n.t(:no_valid_priority)
  }

  after_initialize :set_default_values

  def error?
    priority == :error
  end

  def warning?
    priority == :warning
  end

  def info?
    priority == :info
  end

  def debug?
    priority == :debug
  end

  def to_html
    I18n.t("messages.html.#{self.class.name.underscore}", data)
  end

  def to_text_mail
    I18n.t("messages.text_mail.#{self.class.name.underscore}", data)
  end

  def to_json
    {
      'type' => self.class.name.underscore
    }
  end

  protected

  def set_default_values
    self.data ||= {}
    self.priority ||= default_priority
  end

  def default_priority
    :error
  end
end

class FeedInvalidUrlError < Message
end

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

  def to_json
    {
      'type' => self.class.name.underscore,
      'code' => code,
      'message' => message
    }
  end
end

class FeedValidationError < Message
  validates :kind, inclusion: {
    in: [:no_xml, :no_json, :unknown_version, :invalid_xml, :invalid_json]
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
    I18n.t("messages.html.feed_validation_error.#{kind}", data)
  end

  def to_text_mail
    I18n.t("messages.text_mail.feed_validation_error.#{kind}", data)
  end

  def to_json
    {
      'type' => self.class.name.underscore,
      'kind' => kind,
      'version' => version,
      'message' => message
    }
  end
end

class SourceListChanged < Message
  validates :kind, inclusion: {
    in: [:new_source, :source_archived, :source_reactivated]
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

  def to_json
    {
      'type' => self.class.name.underscore,
      'kind' => kind,
      'name' => name,
      'url' => url
    }
  end
end

class FeedChanged < Message
  validates :kind, inclusion: {
    in: [:created, :updated, :deleted]
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

  def to_html
    I18n.t("messages.html.feed_updated.#{kind}", data)
  end

  def to_text_mail
    I18n.t("messages.text_mail.feed_updated.#{kind}", data)
  end

  def to_json
    {
      'type' => self.class.name.underscore,
      'kind' => kind,
      'name' => name,
    }
  end
end

class FeedUrlUpdatedInfo < Message
  def default_priority
    :info
  end

  def old_url
    data[:old_url]
  end

  def old_url=(url)
    data[:old_url] = url
  end

  def new_url
    data[:new_url]
  end

  def new_url=(url)
    data[:new_url] = url
  end
end
