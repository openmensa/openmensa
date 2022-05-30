# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  discard_on ActiveJob::DeserializationError

  # See https://github.com/bensheldon/good_job#activejob-concurrency
  include GoodJob::ActiveJobExtensions::Concurrency
end
