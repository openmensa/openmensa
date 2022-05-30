# frozen_string_literal: true

class UpdateFeedsJob < ApplicationJob
  queue_as :default

  good_job_control_concurrency_with(
    total_limit: 1,
    key: "UpdateFeedsJob"
  )

  def perform
    OpenMensa::UpdateFeedsTask.new.do
  end
end
