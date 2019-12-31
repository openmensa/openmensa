# frozen_string_literal: true

require 'spec_helper'
require 'nokogiri'

describe OpenMensa::FeedValidator do
  let(:valid_xml_v1) { Nokogiri::XML::Document.parse mock_content('canteen_feed.xml') }
  let(:valid_xml)    { Nokogiri::XML::Document.parse mock_content('feed_v2.xml') }
  let(:invalid_xml)  { Nokogiri::XML::Document.parse mock_content('feed_wellformated.xml') }
  let(:non_om_xml)   { Nokogiri::XML::Document.parse mock_content('carrier_ship.xml') }

  let(:doc_v1)  { Nokogiri::XML::Document.parse mock_content('canteen_feed.xml') }
  let(:doc_v2)  { Nokogiri::XML::Document.parse mock_content('feed_v2.xml') }
  let(:doc_v21) { Nokogiri::XML::Document.parse mock_content('feed_v21.xml') }

  describe '#valid?' do
    it 'returns true on valid feeds' do
      expect(described_class.new(valid_xml)).to be_valid
    end

    it 'returns false on valid feed in wrong version' do
      expect(described_class.new(doc_v2, version: 1)).not_to be_valid
      expect(described_class.new(doc_v1, version: 2)).not_to be_valid
    end

    it 'returns false on invalid XML' do
      expect(described_class.new(invalid_xml)).not_to be_valid
    end

    it 'returns false on non OpenMensa XML' do
      expect(described_class.new(non_om_xml)).not_to be_valid
    end
  end

  describe '#validate!' do
    it 'returns version on valid feeds (1)' do
      expect(described_class.new(valid_xml_v1).validate!).to eq(1)
    end

    it 'returns version on valid feeds (2)' do
      expect(described_class.new(valid_xml).validate!).to eq(2)
    end

    it 'raises an error on invalid XML' do
      expect do
        described_class.new(invalid_xml).validate!
      end.to raise_error(OpenMensa::FeedValidator::FeedValidationError)
    end

    it 'raises an error on non OpenMensa XML' do
      expect do
        described_class.new(non_om_xml).validate!
      end.to raise_error(OpenMensa::FeedValidator::InvalidFeedVersionError)
    end
  end

  describe '#validate' do
    it 'returns version on valid feeds (1)' do
      expect(described_class.new(valid_xml_v1).validate).to eq(1)
    end

    it 'returns version on valid feeds (2)' do
      expect(described_class.new(valid_xml).validate).to eq(2)
    end

    it 'returns false on invalid XML' do
      expect(described_class.new(invalid_xml).validate).to eq(false)
    end

    it 'returns false on non OpenMensa XML' do
      expect(described_class.new(non_om_xml).validate).to eq(false)
    end
  end

  describe '#validated?' do
    it 'returns false before validating a feed' do
      expect(described_class.new(valid_xml)).not_to be_validated
    end

    it 'returns true after validating valid feeds' do
      described_class.new(valid_xml).tap do |vd|
        vd.validate!
        expect(vd).to be_validated
      end
    end
  end

  describe '#version' do
    it 'returns version after validating a feed (v1)' do
      described_class.new(doc_v1).tap do |vd|
        vd.validate!
        expect(vd.version).to eq('1.0')
      end
    end

    it 'returns version after validating a feed (v2)' do
      described_class.new(doc_v2).tap do |vd|
        vd.validate!
        expect(vd.version).to eq('2.0')
      end
    end

    it 'returns version after validating a feed (v21)' do
      described_class.new(doc_v21).tap do |vd|
        vd.validate!
        expect(vd.version).to eq('2.1')
      end
    end

    it 'returns version after validating a feed (v21) and given fixed version' do
      described_class.new(doc_v21, version: 2).tap do |vd|
        vd.validate!
        expect(vd.version).to eq('2.1')
      end
    end
  end
end
