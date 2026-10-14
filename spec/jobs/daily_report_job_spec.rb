# frozen_string_literal: true

require "spec_helper"

describe DailyReportJob do
  let(:parser) { create(:parser) }
  let(:delivery) do
    instance_double(ActionMailer::MessageDelivery, deliver_now: true)
  end
  let(:null_message) { ActionMailer::Base::NullMail.new }

  before { Timecop.freeze }

  describe "#perform" do
    it "issues daily_report for parser" do
      allow(ParserMailer).to receive(:daily_report)
        .with(parser, nil)
        .and_return(null_message)

      DailyReportJob.perform_now(parser_id: parser.id)

      expect(parser.reload.last_report_at).to be_nil
    end

    it "sets last_report_at for generated mails" do
      allow(ParserMailer).to receive(:daily_report)
        .with(parser, nil)
        .and_return(delivery)

      DailyReportJob.perform_now(parser_id: parser.id)

      expect(parser.reload.last_report_at).to be_within(1).of(Time.zone.now)
    end

    it "uses and set last_report_at for genereated mails" do
      parser.update(last_report_at: 1.day.ago)
      parser.reload # reload to get actual stored millisecond precision from database

      allow(ParserMailer).to receive(:daily_report)
        .with(parser, parser.last_report_at)
        .and_return(delivery)

      DailyReportJob.perform_now(parser_id: parser.id)

      expect(parser.reload.last_report_at).to be_within(1).of(Time.zone.now)
    end

    context "with mail delivery errors" do
      let(:delivery) { instance_double(ActionMailer::MessageDelivery) }

      before do
        allow(ParserMailer).to receive(:daily_report).and_return(delivery)
        allow(delivery).to receive(:deliver_now).and_raise(error)
      end

      context "with permanently rejected recipient" do
        let(:error) do
          Net::SMTPFatalError.new(
            "556 5.1.10 <noreply@example.com>: Recipient address rejected: " \
            "Domain example.com does not accept mail (nullMX)",
          )
        end

        it "skips the report without retrying" do
          DailyReportJob.perform_later(parser_id: parser.id)
          perform_enqueued_jobs

          expect(delivery).to have_received(:deliver_now).once
          expect(DailyReportJob).not_to have_been_enqueued
          expect(parser.reload.last_report_at).to be_nil
        end
      end

      context "with other permanent error" do
        let(:error) do
          Net::SMTPFatalError.new("554 5.7.1 <noreply@example.org>: Relay access denied")
        end

        it "raises the error" do
          expect { DailyReportJob.perform_now(parser_id: parser.id) }.to raise_error(Net::SMTPFatalError)
          expect(parser.reload.last_report_at).to be_nil
        end
      end

      context "with temporarily rejected recipient" do
        let(:error) do
          Net::SMTPServerBusy.new(
            "450 4.1.2 <noreply@noreply.noreply>: Recipient address rejected: Domain not found",
          )
        end

        it "retries the report" do
          DailyReportJob.perform_later(parser_id: parser.id)
          perform_enqueued_jobs

          expect(DailyReportJob).to have_been_enqueued
            .with(parser_id: parser.id)
            .at(a_value_within(10.minutes).of(1.hour.from_now))
        end

        it "skips the report after a few retries" do
          DailyReportJob.perform_later(parser_id: parser.id)
          perform_enqueued_jobs
          perform_scheduled_jobs

          expect(delivery).to have_received(:deliver_now).exactly(6).times
          expect(DailyReportJob).not_to have_been_enqueued
          expect(parser.reload.last_report_at).to be_nil
        end
      end

      context "with other temporary error" do
        let(:error) { Net::ReadTimeout.new }

        it "retries the report" do
          DailyReportJob.perform_later(parser_id: parser.id)
          perform_enqueued_jobs

          expect(DailyReportJob).to have_been_enqueued.with(parser_id: parser.id)
        end

        it "raises the error after a few retries" do
          DailyReportJob.perform_later(parser_id: parser.id)
          perform_enqueued_jobs

          expect { perform_scheduled_jobs }.to raise_error(Net::ReadTimeout)

          expect(delivery).to have_received(:deliver_now).exactly(6).times
          expect(parser.reload.last_report_at).to be_nil
        end
      end
    end

    it "limits concurrent reports per parser" do
      2.times { DailyReportJob.perform_later(parser_id: parser.id) }
      DailyReportJob.perform_later(parser_id: create(:parser).id)

      expect(DailyReportJob).to have_been_enqueued.with(parser_id: parser.id).once
      expect(DailyReportJob).to have_been_enqueued.exactly(2).times
    end
  end
end
