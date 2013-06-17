require "spec_helper"

describe MenuMailer do
  describe 'today_menu' do
    let(:user) { FactoryGirl.create :developer }
    let(:canteens) { [ FactoryGirl.create(:canteen) ] }
    let(:mail) { MenuMailer.today_menu(user, canteens, Date.today) }
    let(:content) { mail.body.encoded }

    it 'should sent to the user\'s eMail' do
      mail.to.should == [user.email]
    end

    it 'should contains openmensa in subject' do
      mail.subject.should include('OpenMensa')
    end

    it 'should send in the name of the OpenMensa development team' do
      mail.from.should == ['mail@openmensa.org']
    end

    it 'should contain the date as human string' do
      content.should include(Date.today.to_s)
    end

    context 'with a canteen with meals' do
      let(:canteens) { [ FactoryGirl.create(:canteen, :with_meals) ] }
      let(:canteen) { canteens[0] }
      let(:meals) { Day.find_by(canteen: canteen, date: Date.today).meals }

      it 'should contain the canteen name' do
        content.should include(canteen.name)
      end

      it 'should contain a link to the canteen menu' do
        content.should include("http://localhost:3000/c/#{canteen.id}/#{Date.today}")
      end

      it 'should cantain the category names' do
        content.should include(meals[0].category)
        content.should include(meals[0].name)
      end

      it 'should cantain a ordered list of meals' do
        mealPositions = []
        meals.order(:pos).each do |meal|
          mealPositions << content.index(meal.name)
        end

        mealPositions.should == mealPositions.sort
      end
    end

    context 'without meals' do
      it 'should contain a hint about missing data' do
        content.should include('Keine Essensinformationen')
      end
    end

    context 'with a closed day' do
      it 'should contain a hint about the closed canteen' do
        FactoryGirl.create :day, canteen: canteens[0], closed: true, date: Date.today
        content.should include('Die Mensa ist geschlossen!')
      end
    end
  end
end
