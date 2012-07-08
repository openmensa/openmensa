require 'spec_helper'

describe Cafeteria do
  let(:cafeteria) { FactoryGirl.create :cafeteria, url: 'http://example.com/caf.xml' }

  it { should_not accept_values_for(:name, nil, "") }
  it { should_not accept_values_for(:address, nil, "") }
  it { should_not accept_values_for(:url, nil, "") }
  it { should_not accept_values_for(:user_id, nil, "") }

  describe "#fetch" do
    before do
      stub_request(:any, "example.com/caf.xml").
        to_return(:body => mock_file("cafeteria_feed.xml"), :status => 200)
    end

    xit "should fetch meals from remote source" do
      cafeteria.fetch

      cafeteria.meals.should have(9).items
    end
  end
end
