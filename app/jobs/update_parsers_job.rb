# frozen_string_literal: true

class UpdateParsersJob < ApplicationJob
  queue_as :default

  good_job_control_concurrency_with(
    total_limit: 1,
    key: "UpdateParsersJob",
  )

  def perform
    OpenMensa::UpdateParsersTask.new.do
  end
end
