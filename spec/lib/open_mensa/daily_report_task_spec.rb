require 'spec_helper'
require_dependency 'message'

describe OpenMensa::DailyReportTask do
  let(:task) { OpenMensa::DailyReportTask.new }
  let(:user) { FactoryGirl.create :user }
  let(:developer) { FactoryGirl.create :developer, last_report_at: Time.zone.now - 1.day }
  let(:canteen) { FactoryGirl.create :canteen, user: developer }

  context '#do' do
    it 'should not send mail to user' do
      user
      expect(MessageMailer).not_to receive(:daily_report)
      task.do
    end

    it 'should not send mail to developer without last_report_at' do
      developer.send_reports = false
      developer.save!
      expect(developer.last_report_at).to be_nil
      expect(developer.send_reports?).to be_falsey
      FactoryGirl.create :feedValidationError, canteen: canteen
      expect(MessageMailer).not_to receive(:daily_report)
      task.do
    end

    it 'should not send mail to developer without messages since last_report_at' do
      e = FactoryGirl.create :feedValidationError, canteen: canteen, created_at: developer.last_report_at - 2.minutes
      expect(MessageMailer).not_to receive(:daily_report)
      task.do
    end

    it 'should send mail to developers with messages' do
      e = FactoryGirl.create :feedValidationError, canteen: canteen
      expect(MessageMailer).to receive(:daily_report).with(developer, [e]).and_return(double(deliver: true))
      task.do
    end

    it 'should updated last_report_at time' do
      e = FactoryGirl.create :feedValidationError, canteen: canteen
      expect(MessageMailer).to receive(:daily_report).with(developer, [e]).and_return(double(deliver: true))
      task.do
      developer.reload
      expect(developer.last_report_at).to be >= e.created_at
    end
  end
end
