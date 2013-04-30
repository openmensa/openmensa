require 'spec_helper'
require_dependency 'message'

describe OpenMensa::DailyReportTask do
  let(:task) { OpenMensa::DailyReportTask.new }
  let(:user) { FactoryGirl.create :user }
  let(:developer) { FactoryGirl.create :developer, last_report_at: Time.zone.now - 1.day }
  let(:canteen) { FactoryGirl.create :canteen, user: developer }

  context "#do" do
    it 'should not send mail to user' do
      user
      MessageMailer.should_not_receive(:daily_report)
      task.do
    end

    it 'should not send mail to developer without last_report_at' do
      developer.send_reports = false
      developer.save!
      developer.last_report_at.should be_nil
      developer.send_reports?.should be_false
      FactoryGirl.create :feedValidationError, canteen: canteen
      MessageMailer.should_not_receive(:daily_report)
      task.do
    end

    it 'should not send mail to developer without messages since last_report_at' do
      e = FactoryGirl.create :feedValidationError, canteen: canteen, created_at: developer.last_report_at - 2.minutes
      MessageMailer.should_not_receive(:daily_report)
      task.do
    end

    it 'should send mail to developers with messages' do
      e = FactoryGirl.create :feedValidationError, canteen: canteen
      MessageMailer.should_receive(:daily_report).with(developer, [e]).and_return(double(deliver: true))
      task.do
    end

    it 'should updated last_report_at time' do
      e = FactoryGirl.create :feedValidationError, canteen: canteen
      MessageMailer.should_receive(:daily_report).with(developer, [e]).and_return(double(deliver: true))
      task.do
      developer.reload
      developer.last_report_at.should >= e.created_at
    end
  end
end
