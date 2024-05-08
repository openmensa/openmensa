# frozen_string_literal: true

class DailyReportsJob < ApplicationJob
  queue_as :default

  def perform
    Parser.find_each do |parser|
      DailyReportJob.perform_later(parser_id: parser.id)
    end
  end
end
