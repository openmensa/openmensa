# frozen_string_literal: true

require "open-uri"
require_dependency "message"

class OpenMensa::BaseUpdater
  attr_reader :errors, :version, :data, :document

  def reset_stats
    @changed = false
    @errors = []
  end

  def changed?
    @changed
  end

  # validate XML document
  def validate!
    OpenMensa::FeedValidator.new(document, version: @min_version).tap do |validator|
      @version = validator.version
      validator.validate!
    end
    version
  rescue OpenMensa::FeedValidator::InvalidFeedVersionError
    create_validation_error! :unknown_version
    false
  rescue OpenMensa::FeedValidator::FeedValidationError => e
    e.errors.take(2).each do |error|
      create_validation_error! :invalid_xml, error.message
    end
    false
  end

  private

  def create_validation_error!(kind, message = nil)
    @errors << FeedValidationError.create!(messageable:,
      version:,
      message:,
      kind:)
  end

  def create_fetch_error!(message, code = nil)
    @errors << FeedFetchError.create(messageable:,
      message:,
      code:)
  end

  def extract_canteen_node
    case version.to_i
      when 1
        @document.root
      when 2
        node = @document.root.children.first
        node = node.next while node.name != "canteen"
        node
    end
  end
end
