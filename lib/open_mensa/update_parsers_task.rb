class OpenMensa::UpdateParsersTask
  def do
    Rails.logger.info "[#{Time.zone.now}] Fetch parser index data..."

    Parser.all.pluck(:id).each do |parser_id|
      parser = Parser.find parser_id
      next unless parser.index_url.present?

      OpenMensa::ParserUpdater.new(parser).sync

      GC.start
    end
  end
end
