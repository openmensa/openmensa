# frozen_string_literal: true

require "spec_helper"
include Nokogiri

describe OpenMensa::ParserUpdater do
  let(:parser) { FactoryBot.create :parser, index_url: "http://example.com/index.json" }
  let(:updater) { described_class.new(parser) }

  def stub_data(body)
    stub_request(:any, parser.index_url)
      .to_return(body: body, status: 200)
  end

  def stub_json(json)
    stub_request(:any, parser.index_url)
      .to_return(body: JSON.generate(json), status: 200)
  end

  describe "#fetch" do
    it "skips invalid urls" do
      parser.update_attribute :index_url, ":///:asdf"
      expect(updater.fetch!).to be_falsey
      m = parser.messages.first
      expect(m).to be_an_instance_of(FeedInvalidUrlError)
      expect(updater.errors).to eq([m])
    end

    it "receives feed data via http" do
      stub_data "{}"
      expect(updater.fetch!.read).to eq("{}")
    end

    it "updates index url on 301 responses" do
      stub_request(:any, "example.com/301.json")
        .to_return(status: 301, headers: {location: "http://example.com/index.json"})
      stub_data "{}"
      parser.update_attribute :index_url, "http://example.com/301.json"
      expect(updater.fetch!.read).to eq("{}")
      expect(parser.reload.index_url).to eq("http://example.com/index.json")
      m = parser.messages.first
      expect(m).to be_an_instance_of(FeedUrlUpdatedInfo)
      expect(m.old_url).to eq("http://example.com/301.json")
      expect(m.new_url).to eq("http://example.com/index.json")
    end

    it "does not update index url on 302 responses" do
      stub_request(:any, "example.com/302.json")
        .to_return(status: 302, headers: {location: "http://example.com/index.json"})
      stub_data "{}"
      parser.update_attribute :index_url, "http://example.com/302.json"
      expect(updater.fetch!.read).to eq("{}")
      expect(parser.reload.index_url).to eq("http://example.com/302.json")
    end

    it "handles http errors correctly" do
      stub_request(:any, "example.com/500.json")
        .to_return(status: 500)
      parser.update_attribute :index_url, "http://example.com/500.json"
      expect(updater.fetch!).to be_falsey
      m = parser.messages.first
      expect(m).to be_an_instance_of(FeedFetchError)
      expect(m.code).to eq(500)
      expect(updater.errors).to eq([m])
    end

    it "handles network errors correctly" do
      stub_request(:any, "unknowndomain.org")
        .to_raise(SocketError.new("getaddrinfo: Name or service not known"))
      parser.update_attribute :index_url, "http://unknowndomain.org"
      expect(updater.fetch!).to be_falsey
      m = parser.messages.first
      expect(m).to be_an_instance_of(FeedFetchError)
      expect(m.code).to eq(nil)
      expect(updater.errors).to eq([m])
    end

    it "handles network timeout" do
      stub_request(:any, "example.org/timeout.xml")
        .to_timeout
      parser.update_attribute :index_url, "http://example.org/timeout.xml"
      expect(updater.fetch!).to be_falsey
      m = parser.messages.first
      expect(m).to be_an_instance_of(FeedFetchError)
      expect(m.code).to eq(nil)
      expect(updater.errors).to eq([m])
    end
  end

  describe "#parse" do
    it "parses valid json" do
      stub_data('{"test": "http://example.org/test.xml",
                  "test2": null}')
      expect(updater.fetch!).to be_truthy
      expect(updater.parse!).to eq(
        "test" => "http://example.org/test.xml",
        "test2" => nil
      )
    end

    it "parses valid json" do
      stub_data('{"test": "http://example.org/test.xml",
                  "test2": null}')
      expect(updater.fetch!).to be_truthy
      expect(updater.parse!).to eq(
        "test" => "http://example.org/test.xml",
        "test2" => nil
      )
    end

    it "fails on invalid json" do
      stub_data('{"test": "http://example.org/test.xml",
                  "test2": nil}{')
      expect(updater.fetch!).to be_truthy
      expect(updater.parse!).to be_falsey

      parser.messages.first.tap do |message|
        expect(message).to be_a(FeedValidationError)
        expect(message.kind).to eq(:no_json)
        expect(updater.errors).to eq([message])
      end
    end
  end

  describe "#validate" do
    it "rejects non object documents" do
      stub_data('[["test", "http://test.xml"], ["test2", "http://test.xml"]]')
      expect(updater.fetch!).to be_truthy
      expect(updater.parse!).to be_truthy
      expect(updater.validate!).to be_falsey

      parser.messages.first.tap do |message|
        expect(message).to be_a(FeedValidationError)
        expect(message.kind).to eq(:invalid_json)
        expect(message.version).to eq(nil)
        expect(message.message).to eq("JSON must contain an object with name, url pairs")
        expect(updater.errors).to eq([message])
      end
    end

    it "valid but expected json (invalid value for name)" do
      stub_data('{"test": 4}')
      expect(updater.fetch!).to be_truthy
      expect(updater.parse!).to be_truthy
      expect(updater.validate!).to be_falsey

      parser.messages.first.tap do |message|
        expect(message).to be_a(FeedValidationError)
        expect(message.kind).to eq(:invalid_json)
        expect(message.version).to eq(nil)
        expect(message.message).to eq("URL must be a string or null")
        expect(updater.errors).to eq([message])
      end
    end

    it "valid but expected json (invalid value for name 2)" do
      stub_data('{"test": {"test": "http://test.xml"}}')
      expect(updater.fetch!).to be_truthy
      expect(updater.parse!).to be_truthy
      expect(updater.validate!).to be_falsey

      parser.messages.first.tap do |message|
        expect(message).to be_a(FeedValidationError)
        expect(message.kind).to eq(:invalid_json)
        expect(message.version).to eq(nil)
        expect(message.message).to eq("URL must be a string or null")
        expect(updater.errors).to eq([message])
      end
    end
  end

  describe "#sync" do
    context "create message for new source, but no source/canteen" do
      it "if meta data cannot be fetched" do
        stub_json test: "http://example.org/test.xml"
        stub_request(:any, "http://example.org/test.xml")
          .to_return(status: 500)

        expect(updater.sync).to be_truthy
        expect(updater.stats).to eq new: 1, created: 0, updated: 0, archived: 0
        expect(Canteen.count).to eq 0

        parser.messages.first.tap do |message|
          expect(message).to be_a(SourceListChanged)
          expect(message.kind).to eq(:new_source)
          expect(message.name).to eq "test"
          expect(message.url).to eq "http://example.org/test.xml"
        end
      end

      it "if meta data cannot be fetched" do
        stub_json test: "http://example.org/test.xml"
        stub_request(:any, "http://example.org/test.xml")
          .to_return(body: mock_file("not_complete_metadata.xml"), status: 200)

        expect { updater.sync }.not_to change(Canteen, :count).from 0
        expect(updater.stats).to eq new: 1, created: 0, updated: 0, archived: 0

        parser.messages.first.tap do |message|
          expect(message).to be_a(SourceListChanged)
          expect(message.kind).to eq(:new_source)
          expect(message.name).to eq "test"
          expect(message.url).to eq "http://example.org/test.xml"
        end
      end
    end

    it "create canteen and source for new source with complete meta data" do
      stub_json test: "http://example.org/test.xml"
      stub_request(:any, "http://example.org/test.xml")
        .to_return(body: mock_file("metafeed.xml"), status: 200)

      expect { updater.sync }.to change(Canteen, :count).from(0).to(1)
      expect(updater.stats).to eq new: 0, created: 1, updated: 0, archived: 0

      canteen = Canteen.last

      expect(canteen.name).to eq "Mensa Griebnitzsee"
      expect(canteen.address).to eq "August-Bebel-Str. 89, 14482 Potsdam"
      expect(canteen.city).to eq "Potsdam"
      expect(canteen.phone).to eq "(0331) 977 3749/3748"
      expect(canteen.latitude).to eq 52.3935353446923
      expect(canteen.longitude).to eq 13.1278145313263

      feeds = canteen.feeds.order(:priority)
      expect(feeds.size).to eq 2

      today = feeds.first
      expect(today.name).to eq "today"
      expect(today.priority).to eq 0
      expect(today.url).to eq "http://kaifabian.de/om/potsdam/griebnitzsee.xml?today"
      expect(today.source_url).to eq "http://www.studentenwerk-potsdam.de/mensa-griebnitzsee.html"
      expect(today.retry).to eq [30, 1]
      expect(today.schedule).to eq "0 8-14 * * *"

      full = feeds.second
      expect(full.name).to eq "full"
      expect(full.priority).to eq 1
      expect(full.url).to eq "http://kaifabian.de/om/potsdam/griebnitzsee.xml"
      expect(full.source_url).to eq "http://www.studentenwerk-potsdam.de/speiseplan/"
      expect(full.retry).to eq [60, 5, 1440]
      expect(full.schedule).to eq "0 8 * * 1"

      parser.messages.first.tap do |message|
        expect(message).to be_a(SourceListChanged)
        expect(message.kind).to eq(:new_source)
        expect(message.name).to eq "test"
        expect(message.url).to eq "http://example.org/test.xml"
      end
    end

    it "create message for new source without url" do
      stub_json test: nil

      expect(updater.sync).to be_truthy
      expect(updater.stats).to eq new: 1, created: 0, updated: 0, archived: 0

      parser.messages.first.tap do |message|
        expect(message).to be_a(SourceListChanged)
        expect(message.kind).to eq(:new_source)
        expect(message.name).to eq "test"
        expect(message.url).to be_nil
      end
    end

    it "updates source urls" do
      stub_json test: "http://example.com/test/meta.xml"
      source = FactoryBot.create :source, parser: parser,
                                          name: "test",
                                          meta_url: "http://example.com/test.xml"

      expect(updater.sync).to be_truthy
      expect(updater.stats).to eq new: 0, created: 0, updated: 1, archived: 0
      expect(source.reload.meta_url).to eq "http://example.com/test/meta.xml"

      source.messages.first.tap do |message|
        expect(message).to be_a(FeedUrlUpdatedInfo)
        expect(message.old_url).to eq "http://example.com/test.xml"
        expect(message.new_url).to eq "http://example.com/test/meta.xml"
      end
    end

    it "adds source urls if not existing" do
      stub_json test: "http://example.com/test/meta.xml"
      source = FactoryBot.create :source, parser: parser,
                                          name: "test",
                                          meta_url: nil

      expect(updater.sync).to be_truthy
      expect(updater.stats).to eq new: 0, created: 0, updated: 1, archived: 0
      expect(source.reload.meta_url).to eq "http://example.com/test/meta.xml"

      source.messages.first.tap do |message|
        expect(message).to be_a(FeedUrlUpdatedInfo)
        expect(message.old_url).to be_nil
        expect(message.new_url).to eq "http://example.com/test/meta.xml"
      end
    end

    it "adds source urls if not existing" do
      stub_json({})
      source = FactoryBot.create :source, parser: parser,
                                          name: "test",
                                          meta_url: "http://example.org/test/test2.xml"

      expect(updater.sync).to be_truthy
      expect(updater.stats).to eq new: 0, created: 0, updated: 0, archived: 1
      expect(source.canteen.reload.state).to eq "archived"

      source.messages.first.tap do |message|
        expect(message).to be_a(SourceListChanged)
        expect(message.kind).to eq(:source_archived)
        expect(message.name).to eq "test"
        expect(message.url).to be_nil
      end
    end

    it "reactives a archived source" do
      stub_json test: "http://example.org/test/test2.xml"
      canteen = FactoryBot.create :canteen, state: "archived"
      source = FactoryBot.create :source, parser: parser,
                                          canteen: canteen,
                                          name: "test",
                                          meta_url: "http://example.org/test/test2.xml"

      expect(updater.sync).to be_truthy
      expect(updater.stats).to eq new: 1, created: 0, updated: 0, archived: 0
      expect(source.canteen.reload.state).to eq "new"

      source.messages.first.tap do |message|
        expect(message).to be_a(SourceListChanged)
        expect(message.kind).to eq(:source_reactivated)
        expect(message.name).to eq "test"
        expect(message.url).to eq "http://example.org/test/test2.xml"
      end
    end
  end
end
