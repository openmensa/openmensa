# frozen_string_literal: true

class UpdateSourceJob < ApplicationJob
  queue_as :default

  good_job_control_concurrency_with(
    total_limit: 1,
    key: -> { "#{self.class.name}-#{arguments.first.id}" },
  )

  retry_on StandardError, wait: :polynomially_longer, attempts: 5

  def perform(source)
    return if source.meta_url.blank?
    return if source.canteen.archived?

    OpenMensa::SourceUpdater.new(source).sync
  end
end
