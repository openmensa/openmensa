require 'spec_helper'
require_dependency 'message'

describe OpenMensa::MenuMailsTask do
  let(:task) { OpenMensa::MenuMailsTask.new }
  let(:user) { FactoryGirl.create :user, :with_favs }
  let(:canteens) { user.favorites.map(&:canteen) }
  let(:mail_notification) { FactoryGirl.create :mail_notification, user: user }

  context '#do' do
    it 'should send a menu mail for every mail notification' do
      mail_notification
      MenuMailer.should_receive(:today_menu).with user, canteens, Date.today
      task.do
    end
  end
end
