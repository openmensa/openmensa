class Message < ActiveRecord::Base
  belongs_to :canteen
  serialize :data, Hash
  attr_accessible :data, :priority, :canteen

  validates :priority, inclusion: {
      in: [ :error, :warning, :info, :debug ],
      message: I18n.t(:no_valid_priority)
    }

  after_initialize :set_default_values

  def error?;   priority == :error   end
  def warning?; priority == :warning end
  def info?;    priority == :info    end
  def debug?;   priority == :debug   end

  def to_html
    I18n.t("messages.html.#{self.class.name.underscore}", data)
  end

  def to_text_mail
    I18n.t("messages.text_mail.#{self.class.name.underscore}", data)
  end

  protected
  def set_default_values
    self.data ||= {}
    self.priority ||= default_priority
  end
  def default_priority; :error end
end


class FeedInvalidUrlError < Message
end


class FeedFetchError < Message
  attr_accessible :code, :message

  def code; data[:code] end
  def code=(c); data[:code] = c end
  def message; data[:message] end
  def message=(m); data[:message] = m end
end


class FeedValidationError < Message
  attr_accessible :message, :version, :kind

  validates :kind, inclusion: {
      in: [ :no_xml, :unknown_version, :invalid_xml ],
    }

  def version; data[:version] end
  def version=(v); data[:version] = v end
  def kind; data[:kind] end
  def kind=(m); data[:kind] = m end
  def message; data[:message] end
  def message=(m); data[:message] = m end

  def to_html
    I18n.t("messages.html.feed_validation_error.#{kind.to_s}", data)
  end
  def to_text_mail
    I18n.t("messages.text_mail.feed_validation_error.#{kind.to_s}", data)
  end
end


class FeedUrlUpdatedInfo < Message
  attr_accessible :old_url, :new_url

  def default_priority; :info end
  def old_url; data[:old_url] end
  def old_url=(url); data[:old_url] = url end
  def new_url; data[:new_url] end
  def new_url=(url); data[:new_url] = url end
end
