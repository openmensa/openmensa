# encoding: UTF-8
require File.dirname(__FILE__) + "/../spec_helper"

describe "Canteen" do
  let(:canteen)  { FactoryGirl.create :canteen }
  let(:canteens) { [canteen] + (0..25).map { FactoryGirl.create :canteen }}

  describe "index map" do
    before { canteens }

    it "have markers with links to all canteens", js: true do
      pending "TODO"
    end
  end
end
