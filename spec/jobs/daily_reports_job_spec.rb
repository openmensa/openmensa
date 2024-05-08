# frozen_string_literal: true

require "spec_helper"

RSpec.describe DailyReportsJob do
  let(:parsers) { create_list(:parser, 3) }

  before do
    parsers
  end

  it "schedules a daily report for each parser" do
    DailyReportsJob.perform_now

    expect(DailyReportJob).to have_been_enqueued.with(parser_id: parsers[0].id)
    expect(DailyReportJob).to have_been_enqueued.with(parser_id: parsers[1].id)
    expect(DailyReportJob).to have_been_enqueued.with(parser_id: parsers[2].id)
  end
end
