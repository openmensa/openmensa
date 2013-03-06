require 'spec_helper'
require 'nokogiri'

describe OpenMensa::FeedReader do
  let(:document) { Nokogiri::XML::Document.parse mock_content('feed_v2.xml') }
  let(:reader)   { OpenMensa::FeedReader.new(document, 2) }

  describe '#canteens' do
    it 'should return canteen nodes' do
      reader.canteens.first.should be_a(OpenMensa::FeedReader::CanteenNode)
    end
  end
end
