# frozen_string_literal: true

class OpenMensa::UpdateSourcesTask
  def do
    Rails.logger.info "[#{Time.zone.now}] Fetch sources meta data..."

    Source.pluck(:id).each do |source_id|
      source = Source.find source_id
      next if source.meta_url.blank?
      next if source.canteen.archived?

      OpenMensa::SourceUpdater.new(source).sync
    rescue StandardError => e
      Sentry.capture_exception(e)
      Rails.logger.error(e)
    ensure
      GC.start
    end
  end
end
