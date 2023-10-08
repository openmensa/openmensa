# frozen_string_literal: true

require "spec_helper"
include Nokogiri

describe OpenMensa::SourceUpdater do
  let(:parser) { create(:parser) }
  let(:source) { create(:source, parser:, meta_url: "http://example.com/meta.xml") }
  let(:updater) { OpenMensa::SourceUpdater.new(source) }

  def stub_data(body)
    stub_request(:any, source.meta_url)
      .to_return(body:, status: 200)
  end

  describe "#fetch" do
    it "skips invalid urls" do
      source.update_attribute :meta_url, ":///:asdf"
      expect(updater.fetch!).to be_falsey
      m = source.messages.first
      expect(m).to be_an_instance_of(FeedInvalidUrlError)
      expect(updater.errors).to eq([m])
    end

    it "receives feed data via http" do
      stub_data "<xml>"
      expect(updater.fetch!.read).to eq("<xml>")
    end

    it "updates meta url on 301 responses" do
      stub_request(:any, "example.com/301.xml")
        .to_return(status: 301, headers: {location: "http://example.com/meta.xml"})
      stub_data "<xml>"
      source.update_attribute :meta_url, "http://example.com/301.xml"
      expect(updater.fetch!.read).to eq("<xml>")
      expect(source.reload.meta_url).to eq("http://example.com/meta.xml")
      m = source.messages.first
      expect(m).to be_an_instance_of(FeedUrlUpdatedInfo)
      expect(m.old_url).to eq("http://example.com/301.xml")
      expect(m.new_url).to eq("http://example.com/meta.xml")
    end

    it "does not update meta url on 302 responses" do
      stub_request(:any, "example.com/302.xml")
        .to_return(status: 302, headers: {location: "http://example.com/meta.xml"})
      stub_data "<xml>"
      source.update_attribute :meta_url, "http://example.com/302.xml"
      expect(updater.fetch!.read).to eq("<xml>")
      expect(source.reload.meta_url).to eq("http://example.com/302.xml")
    end

    it "handles http errors correctly" do
      stub_request(:any, "example.com/500.xml")
        .to_return(status: 500)
      source.update_attribute :meta_url, "http://example.com/500.xml"
      expect(updater.fetch!).to be_falsey
      m = source.messages.first
      expect(m).to be_an_instance_of(FeedFetchError)
      expect(m.code).to eq(500)
      expect(updater.errors).to eq([m])
    end

    it "handles network errors correctly" do
      stub_request(:any, "unknowndomain.org")
        .to_raise(SocketError.new("getaddrinfo: Name or service not known"))
      source.update_attribute :meta_url, "http://unknowndomain.org"
      expect(updater.fetch!).to be_falsey
      m = source.messages.first
      expect(m).to be_an_instance_of(FeedFetchError)
      expect(m.code).to be_nil
      expect(updater.errors).to eq([m])
    end

    it "handles network timeout" do
      stub_request(:any, "example.org/timeout.xml")
        .to_timeout
      source.update_attribute :meta_url, "http://example.org/timeout.xml"
      expect(updater.fetch!).to be_falsey
      m = source.messages.first
      expect(m).to be_an_instance_of(FeedFetchError)
      expect(m.code).to be_nil
      expect(updater.errors).to eq([m])
    end
  end

  describe "#parse" do
    it "non-xml data" do
      stub_data mock_content("feed_garbage.dat")
      expect(updater.fetch!).to be_truthy
      expect(updater.parse!).to be_falsey

      source.messages.first.tap do |message|
        expect(message).to be_a(FeedValidationError)
        expect(message.kind).to eq(:no_xml)
        expect(message.version).to be_nil
        expect(updater.errors).to eq([message])
      end
    end
  end

  describe "#validate" do
    it "does not except 1.0 feeds (no meta attributes)" do
      stub_data mock_content("canteen_feed.xml")
      expect(updater.fetch!).to be_truthy
      expect(updater.parse!).to be_truthy
      expect(updater.validate!).to be_falsey

      expect(source.messages.size).to eq 1
      source.messages.first.tap do |message|
        expect(message).to be_a(FeedValidationError)
        expect(message.kind).to eq(:unknown_version)
        expect(message.version).to be_nil
        expect(updater.errors).to eq([message])
      end
    end

    it "returns 2.0 on valid v2.0 openmensa xml feeds" do
      stub_data mock_content("feed_v2.xml")
      expect(updater.fetch!).to be_truthy
      expect(updater.parse!).to be_truthy
      expect(updater.validate!).to eq("2.0")
      expect(updater.version).to eq "2.0"
    end

    it "returns 2.1 on valid v2.1 openmensa xml feeds" do
      stub_data mock_content("feed_v21.xml")
      expect(updater.fetch!).to be_truthy
      expect(updater.parse!).to be_truthy
      expect(updater.validate!).to eq("2.1")
      expect(updater.version).to eq "2.1"
    end

    it "well-formatted but non-valid xml data" do
      stub_data mock_content("feed_wellformated.xml")
      expect(updater.fetch!).to be_truthy
      expect(updater.parse!).to be_truthy
      expect(updater.validate!).to be_falsey

      expect(source.messages.size).to eq 1
      source.messages.first.tap do |message|
        expect(message).to be_a(FeedValidationError)
        expect(message.kind).to eq(:unknown_version)
        expect(message.version).to be_nil
        expect(updater.errors).to eq([message])
      end
    end

    it "valid but non-openmensa xml data" do
      stub_data mock_content("carrier_ship.xml")
      expect(updater.fetch!).to be_truthy
      expect(updater.parse!).to be_truthy
      expect(updater.validate!).to be_falsey

      expect(source.messages.size).to eq 1
      source.messages.first.tap do |message|
        expect(message).to be_a(FeedValidationError)
        expect(message.kind).to eq(:unknown_version)
        expect(message.version).to be_nil
        expect(updater.errors).to eq([message])
      end
    end
  end

  describe "#sync" do
    let(:today_feed) do
      source.feeds.create! name: "today", priority: 0,
        schedule: "0 8-14 * * *", retry: [30, 1],
        url: "http://kaifabian.de/om/potsdam/griebnitzsee.xml?today",
        source_url: "http://www.studentenwerk-potsdam.de/mensa-griebnitzsee.html"
    end
    let(:full_feed) do
      source.feeds.create! name: "full", priority: 1,
        schedule: "0 8 * * 1", retry: [60, 5, 1440],
        url: "http://kaifabian.de/om/potsdam/griebnitzsee.xml",
        source_url: "http://www.studentenwerk-potsdam.de/speiseplan/"
    end

    context "and the metadata" do
      let(:canteen) { source.canteen }

      it "does not create a new data_proposal without data" do
        stub_data mock_content("feed2_empty.xml")

        expect do
          expect(updater.sync).to be_truthy
        end.not_to change { source.canteen.data_proposals.size }
        expect(updater.stats).to eq created: 0, updated: 0, deleted: 0, new_metadata: false
      end

      it "does not create a new data_proposal without data but feeds" do
        stub_data mock_content("single_feed.xml")
        today_feed

        expect do
          expect(updater.sync).to be_truthy
        end.not_to change { source.canteen.data_proposals.size }
        expect(updater.stats).to eq created: 0, updated: 0, deleted: 0, new_metadata: false
      end

      it "creates new data proposal on new data" do
        stub_data mock_content("metafeed.xml")
        today_feed
        full_feed

        expect do
          expect(updater.sync).to be_truthy
        end.to change { source.canteen.data_proposals.size }.from(0).to(1)
        expect(updater.stats).to eq created: 0, updated: 0, deleted: 0, new_metadata: true
      end
    end

    it "creates new feeds" do
      stub_data mock_content("single_feed.xml")

      expect(updater.sync).to be_truthy
      expect(updater.stats).to eq created: 1, updated: 0, deleted: 0, new_metadata: false

      updater.errors.first.tap do |message|
        expect(message).to be_a(FeedChanged)
        expect(message.kind).to eq(:created)
        expect(message.name).to eq "today"
        expect(message.messageable).to be_a(Feed)
      end
    end

    it "does not update unchanged existing feeds" do
      stub_data mock_content("single_feed.xml")
      today_feed

      expect(updater.sync).to be_truthy
      expect(updater.stats).to eq created: 0, updated: 0, deleted: 0, new_metadata: false

      expect(updater.errors).to be_empty
    end

    it "updates changed existing feeds" do
      stub_data mock_content("single_feed.xml")
      source.feeds.create! name: "today", priority: 0,
        schedule: "* 8-14 * * *", retry: [30, 1],
        url: "http://kaifabian.de/om/potsdam/griebnitzsee.xml",
        source_url: "http://www.studentenwerk-potsdam.de/mensa-griebnitzsee.html"

      expect(updater.sync).to be_truthy
      expect(updater.stats).to eq created: 0, updated: 1, deleted: 0, new_metadata: false
      feed = source.feeds[0].reload
      expect(feed.url).to eq "http://kaifabian.de/om/potsdam/griebnitzsee.xml?today"
      expect(feed.schedule).to eq "0 8-14 * * *"

      updater.errors.first.tap do |message|
        expect(message).to be_a(FeedChanged)
        expect(message.kind).to eq(:updated)
        expect(message.name).to eq "today"
        expect(message.messageable).to eq source.feeds[0]
      end
    end

    it "deletes removed feeds" do
      stub_data mock_content("single_feed.xml")
      source.feeds.create! name: "today", priority: 0,
        schedule: "0 8-14 * * *", retry: [30, 1],
        url: "http://kaifabian.de/om/potsdam/griebnitzsee.xml?today",
        source_url: "http://www.studentenwerk-potsdam.de/mensa-griebnitzsee.html"
      source.feeds.create! name: "full", priority: 1,
        schedule: "0 8 * * *",
        url: "http://kaifabian.de/om/potsdam/griebnitzsee.xml",
        source_url: "http://www.studentenwerk-potsdam.de/mensa-griebnitzsee.html"

      expect(updater.sync).to be_truthy
      expect(updater.stats).to eq created: 0, updated: 0, deleted: 1, new_metadata: false
      expect(source.feeds.reload.size).to eq 1

      updater.errors.first.tap do |message|
        expect(message).to be_a(FeedChanged)
        expect(message.kind).to eq(:deleted)
        expect(message.name).to eq "full"
        expect(message.messageable).to eq source
      end
    end
  end
end
