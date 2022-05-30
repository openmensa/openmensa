# frozen_string_literal: true

class UpdateSourcesJob < ApplicationJob
  queue_as :default

  good_job_control_concurrency_with(
    total_limit: 1,
    key: "UpdateSourcesJob"
  )

  def perform
    OpenMensa::UpdateSourcesTask.new.do
  end
end
