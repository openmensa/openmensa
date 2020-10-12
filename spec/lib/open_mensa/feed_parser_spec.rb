# frozen_string_literal: true

require "spec_helper"
require "nokogiri"

describe OpenMensa::FeedParser do
  let(:valid_data)   { mock_content("feed_v2.xml") }
  let(:invalid_data) { mock_content("feed_garbage.dat") }

  describe "#parse" do
    it "returns XML document on valid XML data" do
      expect(described_class.new(valid_data).parse).to be_a(Nokogiri::XML::Document)
    end

    it "returns false on non valid XML data" do
      expect(described_class.new(invalid_data).parse).to eq(false)
    end
  end

  describe "#parse!" do
    it "returns XML document on valid XML data" do
      expect(described_class.new(valid_data).parse!).to be_a(Nokogiri::XML::Document)
    end

    it "raises an error on non valid XML data" do
      expect do
        described_class.new(invalid_data).parse!
      end.to raise_error(::OpenMensa::FeedParser::ParserError)
    end
  end
end
