# frozen_string_literal: true

require "spec_helper"
require_dependency "message"

describe OpenMensa::DailyReportTask do
  let(:task) { described_class.new }
  let(:parsers) { create_list :parser, 3 }
  let(:message) do
    ActionMailer::Base.mail to: "test@example.org",
      from: "info@openmensa.org",
      subject: "test",
      body: "test content"
  end
  let(:null_message) { ActionMailer::Base::NullMail.new }

  before { Timecop.freeze }

  describe "#do" do
    it "issues daily_report for every parser" do
      expect(ParserMailer).to receive(:daily_report).with(parsers[0], nil).and_return(null_message)
      expect(ParserMailer).to receive(:daily_report).with(parsers[1], nil).and_return(null_message)
      expect(ParserMailer).to receive(:daily_report).with(parsers[2], nil).and_return(null_message)

      task.do
    end

    it "sets last_report_at for generated mails" do
      expect(ParserMailer).to receive(:daily_report).with(parsers[0], nil).and_return(message)
      expect(ParserMailer).to receive(:daily_report).with(parsers[1], nil).and_return(message)
      expect(ParserMailer).to receive(:daily_report).with(parsers[2], nil).and_return(null_message)

      task.do

      expect(parsers[0].reload.last_report_at).to be_within(1).of(Time.zone.now)
      expect(parsers[1].reload.last_report_at).to be_within(1).of(Time.zone.now)
    end

    it "uses and set last_report_at for genereated mails" do
      last_reports_at = [1.day.ago, 2.days.ago, 4.years.ago]
      parsers[0].update_attribute :last_report_at, last_reports_at[0]
      parsers[1].update_attribute :last_report_at, last_reports_at[1]
      parsers[2].update_attribute :last_report_at, last_reports_at[2]
      expect(ParserMailer).to receive(:daily_report).with(parsers[0], parsers[0].reload.last_report_at).and_return(message)
      expect(ParserMailer).to receive(:daily_report).with(parsers[1], parsers[1].reload.last_report_at).and_return(message)
      expect(ParserMailer).to receive(:daily_report).with(parsers[2], parsers[2].reload.last_report_at).and_return(ActionMailer::Base::NullMail.new)

      task.do

      expect(parsers[0].reload.last_report_at).to be_within(1).of(Time.zone.now)
      expect(parsers[1].reload.last_report_at).to be_within(1).of(Time.zone.now)
    end
  end
end
