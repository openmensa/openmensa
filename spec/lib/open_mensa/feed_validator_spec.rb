require 'spec_helper'
require 'nokogiri'

describe OpenMensa::FeedValidator do
  let(:valid_xml_v1) { Nokogiri::XML::Document.parse mock_content('canteen_feed.xml') }
  let(:valid_xml)    { Nokogiri::XML::Document.parse mock_content('feed_v2.xml') }
  let(:invalid_xml)  { Nokogiri::XML::Document.parse mock_content('feed_wellformated.xml') }
  let(:non_om_xml)   { Nokogiri::XML::Document.parse mock_content('carrier_ship.xml') }

  let(:doc_v1) { Nokogiri::XML::Document.parse mock_content('canteen_feed.xml') }
  let(:doc_v2)    { Nokogiri::XML::Document.parse mock_content('feed_v2.xml') }

  describe '#valid?' do
    it 'should return true on valid feeds' do
      expect(OpenMensa::FeedValidator.new(valid_xml)).to be_valid
    end

    it 'should return false on invalid XML' do
      expect(OpenMensa::FeedValidator.new(invalid_xml)).not_to be_valid
    end

    it 'should return false on non OpenMensa XML' do
      expect(OpenMensa::FeedValidator.new(non_om_xml)).not_to be_valid
    end
  end

  describe '#validate!' do
    it 'should return version on valid feeds (1)' do
      expect(OpenMensa::FeedValidator.new(valid_xml_v1).validate!).to eq(1)
    end

    it 'should return version on valid feeds (2)' do
      expect(OpenMensa::FeedValidator.new(valid_xml).validate!).to eq(2)
    end

    it 'should raise an error on invalid XML' do
      expect do
        OpenMensa::FeedValidator.new(invalid_xml).validate!
      end.to raise_error(OpenMensa::FeedValidator::FeedValidationError)
    end

    it 'should raise an error on non OpenMensa XML' do
      expect do
        OpenMensa::FeedValidator.new(non_om_xml).validate!
      end.to raise_error(OpenMensa::FeedValidator::InvalidFeedVersionError)
    end
  end

  describe '#validate' do
    it 'should return version on valid feeds (1)' do
      expect(OpenMensa::FeedValidator.new(valid_xml_v1).validate).to eq(1)
    end

    it 'should return version on valid feeds (2)' do
      expect(OpenMensa::FeedValidator.new(valid_xml).validate).to eq(2)
    end

    it 'should return false on invalid XML' do
      expect(OpenMensa::FeedValidator.new(invalid_xml).validate).to eq(false)
    end

    it 'should return false on non OpenMensa XML' do
      expect(OpenMensa::FeedValidator.new(non_om_xml).validate).to eq(false)
    end
  end

  describe '#validated?' do
    it 'should return false before validating a feed' do
      expect(OpenMensa::FeedValidator.new(valid_xml)).not_to be_validated
    end

    it 'should return true after validating valid feeds' do
      OpenMensa::FeedValidator.new(valid_xml).tap do |vd|
        vd.validate!
        expect(vd).to be_validated
      end
    end
  end

  describe '#version' do
    it 'should return version after validating a feed (v1)' do
      OpenMensa::FeedValidator.new(doc_v1).tap do |vd|
        vd.validate!
        expect(vd.version).to eq(1)
      end
    end

    it 'should return version after validating a feed (v2)' do
      OpenMensa::FeedValidator.new(doc_v2).tap do |vd|
        vd.validate!
        expect(vd.version).to eq(2)
      end
    end
  end
end
