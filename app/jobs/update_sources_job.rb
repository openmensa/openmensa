# frozen_string_literal: true

class UpdateSourcesJob < ApplicationJob
  queue_as :default

  good_job_control_concurrency_with(
    total_limit: 1,
    key: name,
  )

  def perform
    Source.find_each do |source|
      UpdateSourceJob.perform_later(source)
    end
  end
end
