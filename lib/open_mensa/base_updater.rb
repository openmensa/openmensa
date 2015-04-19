require 'open-uri'
require_dependency 'message'

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
    OpenMensa::FeedValidator.new(document).tap do |validator|
      @version = validator.version
      validator.validate!
    end
    version
  rescue OpenMensa::FeedValidator::InvalidFeedVersionError
    create_validation_error! :unknown_version
    false
  rescue OpenMensa::FeedValidator::FeedValidationError => err
    err.errors.take(2).each do |error|
      create_validation_error! :invalid_xml, error.message
    end
    fetch.state = 'invalid'
    fetch.save!
    false
  end

  private

  def create_validation_error!(kind, message = nil)
    @errors << FeedValidationError.create!(messageable: messageable,
                                           version: version,
                                           message: message,
                                           kind: kind)
  end

  def create_fetch_error!(message, code = nil)
    @errors << FeedFetchError.create(messageable: messageable,
                                     message: message,
                                     code: code)
  end
end
