# frozen_string_literal: true

class OpenMensa::UpdateSourcesTask
  def do
    Rails.logger.info "[#{Time.zone.now}] Fetch sources meta data..."

    Source.all.pluck(:id).each do |source_id|
      source = Source.find source_id
      next unless source.meta_url.present?
      next if source.canteen.archived?

      OpenMensa::SourceUpdater.new(source).sync

      GC.start
    end
  end
end
