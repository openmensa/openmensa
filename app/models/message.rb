# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :messageable, polymorphic: true

  serialize :payload, coder: SymbolizedHash

  validates :priority, inclusion: {
    in: %w[error warning info debug],
    message: I18n.t(:no_valid_priority),
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
    I18n.t("messages.html.#{self.class.name.underscore}", **payload)
  end

  def to_text_mail
    I18n.t("messages.text_mail.#{self.class.name.underscore}", **payload)
  end

  def to_json(*_args)
    {
      "type" => self.class.name.underscore,
    }
  end

  protected

  def set_default_values
    self.priority ||= default_priority
  end

  def default_priority
    :error
  end
end
