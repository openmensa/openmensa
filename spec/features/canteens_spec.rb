# frozen_string_literal: true

require File.dirname(__FILE__) + "/../spec_helper"

describe "Canteen", type: :feature do
  let(:canteen)  { FactoryBot.create :canteen }
  let(:canteens) { [canteen] + (0..25).map { FactoryBot.create :canteen } }

  describe "index map" do
    before { canteens }

    it "have markers with links to all canteens", js: true do
      skip "TODO"
    end
  end

  describe "#show" do
    it "lists the canteens telephone number" do
      canteen.update_attribute :phone, "0331 243 580/051"

      visit canteen_path(canteen)

      expect(page).to have_content "0331 243 580/051"
    end

    it "lists the canteens email address" do
      canteen.update_attribute :email, "test@example.org"

      visit canteen_path(canteen)

      expect(page).to have_content "test@example.org"
    end

    context "parser info" do
      let(:owner) { FactoryBot.create :developer }
      let(:parser) { FactoryBot.create :parser, user: owner }
      let!(:source) { FactoryBot.create :source, parser: parser, canteen: canteen }

      it "pers default not contain any parser info" do
        visit canteen_path(canteen)
        expect(page).not_to have_content("Über Parser")
      end

      it "contains user name if wanted" do
        owner.update public_name: "Hans Otto"
        visit canteen_path(canteen)

        expect(page).to have_content "Der Parser wird von Hans Otto bereitgestellt."
      end

      it "contains a user info page if wanted" do
        info_url = "https://github.com/hansotto"
        owner.update public_name: "Hans Otto", info_url: info_url
        visit canteen_path(canteen)

        expect(page).to have_link_to(info_url)
      end

      it "contains the user public email if wanted" do
        public_email = "test@example.com"
        owner.update public_email: public_email
        visit canteen_path(canteen)

        expect(page).to have_content(public_email)
        expect(page).to have_link_to("mailto:#{public_email}")
      end

      it "contains link to parser page if provided" do
        info_url = "https://github.com/hansotto/om-parser"
        parser.update info_url: info_url
        visit canteen_path(canteen)

        expect(page).to have_link_to(info_url)
        expect(page).to have_content(info_url)
      end
    end
  end
end
