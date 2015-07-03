require 'spec_helper'
require_dependency 'message'

describe OpenMensa::FeedLoader do
  let(:feed) { FactoryGirl.create :feed, url: 'http://example.com/canteen_feed.xml' }
  let(:loader) { OpenMensa::FeedLoader.new(feed, :url) }

  before do
    stub_request(:any, 'example.com/canteen_feed.xml')
      .to_return(body: mock_file('canteen_feed.xml'), status: 200)
    stub_request(:any, 'example.com/data.xml')
      .to_return(body: '<xml>', status: 200)
    stub_request(:any, 'example.com/301.xml')
      .to_return(status: 301, headers: {location: 'http://example.com/data.xml'})
    stub_request(:any, 'example.com/302.xml')
      .to_return(status: 302, headers: {location: 'http://example.com/data.xml'})
    stub_request(:any, 'example.com/303.xml')
      .to_return(status: 303, headers: {location: 'http://example.com/data.xml'})
    stub_request(:any, 'example.com/307.xml')
      .to_return(status: 307, headers: {location: 'http://example.com/data.xml'})
    stub_request(:any, 'example.com/307-2.xml')
      .to_return(status: 307, headers: {location: 'http://example.com/307.xml'})
    stub_request(:any, 'example.com/307-3.xml')
      .to_return(status: 307, headers: {location: 'http://example.com/307-2.xml'})
    stub_request(:any, 'example.com/500.xml')
      .to_return(status: 500)
    stub_request(:any, 'unknowndomain.org')
      .to_raise(SocketError.new('getaddrinfo: Name or service not known'))
    stub_request(:any, 'example.org/timeout.xml')
      .to_timeout
  end

  describe '#load!' do
    it 'should load data from canteen URL' do
      expect(loader.load!.read).to eq(mock_content('canteen_feed.xml'))
    end

    it 'should follow temporary redirects (1)' do
      feed.url = 'http://example.com/307.xml'
      expect(loader.load!.read).to eq('<xml>')
    end

    it 'should follow temporary redirects (2)' do
      feed.url = 'http://example.com/302.xml'
      expect(loader.load!.read).to eq('<xml>')
    end

    it 'should follow temporary redirects (3)' do
      feed.url = 'http://example.com/303.xml'
      expect(loader.load!.read).to eq('<xml>')
    end

    it 'should follow temporary redirects for a maximum of 2 redirect by default' do
      feed.url = 'http://example.com/307-3.xml'
      expect do
        loader.load!
      end.to raise_error(OpenMensa::FeedLoader::FeedLoadError)
    end

    it 'should follow update canteen URL on permanent redirect' do
      feed.url = 'http://example.com/301.xml'
      loader.load!

      expect(feed.url).to eq('http://example.com/data.xml')
    end

    it 'should raise an error on 500' do
      feed.url = 'http://example.com/500.xml'
      expect do
        loader.load!
      end.to raise_error(OpenMensa::FeedLoader::FeedLoadError)
    end

    it 'should raise an error on socket error' do
      feed.url = 'http://unknowndomain.org/'
      expect do
        loader.load!
      end.to raise_error(OpenMensa::FeedLoader::FeedLoadError)
    end

    it 'should raise an error on timeout' do
      feed.url = 'http://example.org/timeout.xml'
      expect do
        loader.load!
      end.to raise_error(OpenMensa::FeedLoader::FeedLoadError)
    end
  end
end
