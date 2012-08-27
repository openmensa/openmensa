require File.dirname(__FILE__) + '/../../lib/open_mensa.rb'

describe OpenMensa::Updater do
  context "should reject" do
    it "non-xml data" do
      pending
    end
    it "non-valid xml data" do
      pending
    end
    it "valid but non-openmensa xml data" do
      pending
    end
  end
  it "accept valid openmensa xml feeds" do
    pending
  end
  context "with valid v2 feed" do
    it 'ignore empty feeds' do
      pending
    end
    context 'with new data' do
      it 'should add days and meals entries' do
        pending
      end
      it 'should add prices for meals' do
        pending
      end
      it 'should add correct notes for meals' do
        pending
      end
      it 'should add closed days entries' do
        pending
      end
      it 'should update last_fetch_at and not last_changed_at' do
        pending
      end
    end
    context 'with old data' do
      it 'should allow to close the canteen on given days' do
        pending
      end
      it 'should allow to reopen a canteen on given days' do
        pending
      end
      it 'should add new meals' do
        pending
      end
      it 'should drop disappeared meals' do
        pending
      end
      it 'should update changed meals' do
        pending
      end
      it 'should not update last_changed_at on unchanged meals' do
        pending
      end
      it 'should update last_fetch_at and not last_changed_at' do
        pending
      end
    end
  end
end
