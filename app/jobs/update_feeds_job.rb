# frozen_string_literal: true

class UpdateFeedsJob < ApplicationJob
  queue_as :default

  good_job_concurrency_rule(
    label: "UpdateFeedsJob",
    apply_label: true,
    total_limit: 1,
  )

  def perform
    OpenMensa::UpdateFeedsTask.new.do
  end
end
