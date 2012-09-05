require "spec_helper"

describe MessageMailer do
  describe 'daily_report' do
    let(:user) { FactoryGirl.create :user }
    let(:canteens) {[
      FactoryGirl.create(:canteen, user: user),
      FactoryGirl.create(:canteen, user: user),
      FactoryGirl.create(:canteen, user: user)
    ]}
    let(:messages) {[
      FactoryGirl.create(:feedInvalidUrlError, canteen: canteens[0]),
      FactoryGirl.create(:feedFetchError, canteen: canteens[0]),
      FactoryGirl.create(:feedValidationError, canteen: canteens[0], kind: :invalid_xml),
      FactoryGirl.create(:feedUrlUpdatedInfo, canteen: canteens[1])
    ]}
    let(:mail) { MessageMailer.daily_report(user) }

    it 'should sent to the user\'s eMail' do
      mail.to.should == [user.email]
    end

    it 'should contains openmensa in subject' do
      mail.subject.should include('OpenMensa')
    end

    it 'should send in the name of the OpenMensa development team' do
      mail.from.should == ['info@openmensa.org']
    end

    it 'should include all new messages for every canteen' do
      messages # create messages

      content = mail.body.encoded
      content.should include(canteens[0].name)
      content.should include(messages[1].code.to_s)
      content.should include(messages[1].message)
      content.should include(messages[2].version.to_s)
      content.should include(messages[2].message)

      content.should include(canteens[1].name)
      content.should include(messages[3].old_url)
      content.should include(messages[3].new_url)
    end

    it 'should not contain canteens without message' do
      mail.body.encoded.should_not include(canteens[2].name)
    end
  end
end
