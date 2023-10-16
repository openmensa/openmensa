# frozen_string_literal: true

class OpenMensa::UpdateParsersTask
  def do
    Rails.logger.info "[#{Time.zone.now}] Fetch parser index data..."

    Parser.pluck(:id).each do |parser_id|
      parser = Parser.find parser_id
      next if parser.index_url.blank?

      OpenMensa::ParserUpdater.new(parser).sync

      GC.start
    end
  end
end
