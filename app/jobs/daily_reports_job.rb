# frozen_string_literal: true

class DailyReportsJob < ApplicationJob
  queue_as :default

  good_job_control_concurrency_with(
    total_limit: 1,
    key: "DailyReportsJob"
  )

  def perform
    OpenMensa::DailyReportTask.new.do
  end
end
