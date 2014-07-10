require "spec_helper"

describe MessageMailer, :type => :mailer do
  describe 'daily_report' do
    let(:user) { FactoryGirl.create :developer }
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
      expect(mail.to).to eq([user.email])
    end

    it 'should contains openmensa in subject' do
      expect(mail.subject).to include('OpenMensa')
    end

    it 'should send in the name of the OpenMensa development team' do
      expect(mail.from).to eq(['mail@openmensa.org'])
    end

    it 'should include all new messages for every canteen' do
      messages # create messages

      content = mail.body.encoded
      expect(content).to include(canteens[0].name)
      expect(content).to include(messages[1].code.to_s)
      expect(content).to include(messages[1].message)
      expect(content).to include(messages[2].version.to_s)
      expect(content).to include(messages[2].message)

      expect(content).to include(canteens[1].name)
      expect(content).to include(messages[3].old_url)
      expect(content).to include(messages[3].new_url)
    end

    it 'should not contain canteens without message' do
      expect(mail.body.encoded).not_to include(canteens[2].name)
    end
  end
end
