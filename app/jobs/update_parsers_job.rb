# frozen_string_literal: true

class UpdateParsersJob < ApplicationJob
  queue_as :default

  good_job_concurrency_rule(
    label: "UpdateParsersJob",
    apply_label: true,
    total_limit: 1,
  )

  def perform
    OpenMensa::UpdateParsersTask.new.do
  end
end
