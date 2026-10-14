# frozen_string_literal: true

class UpdateSourcesJob < ApplicationJob
  queue_as :default

  good_job_concurrency_rule(
    label: name,
    apply_label: true,
    total_limit: 1,
  )

  def perform
    Source.find_each do |source|
      UpdateSourceJob.perform_later(source)
    end
  end
end
