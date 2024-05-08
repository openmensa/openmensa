# frozen_string_literal: true

require "spec_helper"

describe DailyReportJob do
  let(:parser) { create(:parser) }
  let(:message) do
    ActionMailer::Base.mail(
      to: "test@example.org",
      from: "info@openmensa.org",
      body: "test content"
    )
  end
  let(:null_message) { ActionMailer::Base::NullMail.new }

  before { Timecop.freeze }

  describe "#perform" do
    it "issues daily_report for parser" do
      expect(ParserMailer).to receive(:daily_report)
        .with(parser, nil)
        .and_return(null_message)

      DailyReportJob.perform_now(parser_id: parser.id)

      expect(parser.reload.last_report_at).to be_nil
    end

    it "sets last_report_at for generated mails" do
      expect(ParserMailer).to receive(:daily_report)
        .with(parser, nil)
        .and_return(message)

      DailyReportJob.perform_now(parser_id: parser.id)

      expect(parser.reload.last_report_at).to be_within(1).of(Time.zone.now)
    end

    it "uses and set last_report_at for genereated mails" do
      parser.update(last_report_at: 1.day.ago)
      parser.reload # reload to get actual stored millisecond precision from database

      expect(ParserMailer).to receive(:daily_report)
        .with(parser, parser.last_report_at)
        .and_return(message)

      DailyReportJob.perform_now(parser_id: parser.id)

      expect(parser.reload.last_report_at).to be_within(1).of(Time.zone.now)
    end
  end
end
