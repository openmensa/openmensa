require 'spec_helper'
require_dependency 'message'

describe OpenMensa::FeedLoader do
  let(:canteen) { FactoryGirl.create :canteen, url: 'http://example.com/canteen_feed.xml' }
  let(:loader) { OpenMensa::FeedLoader.new(canteen) }
  let(:today_loader) { OpenMensa::FeedLoader.new(canteen, today: true) }

  before do
    stub_request(:any, 'example.com/canteen_feed.xml').
        to_return(:body => mock_file('canteen_feed.xml'), :status => 200)
    stub_request(:any, 'example.com/data.xml').
        to_return(:body => '<xml>', :status => 200)
    stub_request(:any, 'example.com/301.xml').
        to_return(status: 301, headers: { location: 'http://example.com/data.xml' })
    stub_request(:any, 'example.com/302.xml').
        to_return(status: 302, headers: { location: 'http://example.com/data.xml' })
    stub_request(:any, 'example.com/303.xml').
        to_return(status: 303, headers: { location: 'http://example.com/data.xml' })
    stub_request(:any, 'example.com/307.xml').
        to_return(status: 307, headers: { location: 'http://example.com/data.xml' })
    stub_request(:any, 'example.com/307-2.xml').
        to_return(status: 307, headers: { location: 'http://example.com/307.xml' })
    stub_request(:any, 'example.com/307-3.xml').
        to_return(status: 307, headers: { location: 'http://example.com/307-2.xml' })
    stub_request(:any, 'example.com/500.xml').
        to_return(status: 500)
    stub_request(:any, 'unknowndomain.org').
        to_raise(SocketError.new('getaddrinfo: Name or service not known'))
    stub_request(:any, 'example.org/timeout.xml').
        to_timeout
  end

  describe '#load!' do
    it 'should load data from canteen URL' do
      loader.load!.read.should == mock_content('canteen_feed.xml')
    end

    it 'should load data from canteen today URL' do
      canteen.today_url = 'http://example.com/data.xml'
      today_loader.load!.read.should == '<xml>'
    end

    it 'should follow temporary redirects (1)' do
      canteen.url = 'http://example.com/307.xml'
      loader.load!.read.should == '<xml>'
    end

    it 'should follow temporary redirects (2)' do
      canteen.url = 'http://example.com/302.xml'
      loader.load!.read.should == '<xml>'
    end

    it 'should follow temporary redirects (3)' do
      canteen.url = 'http://example.com/303.xml'
      loader.load!.read.should == '<xml>'
    end

    it 'should follow temporary redirects for a maximum of 2 redirect by default' do
      canteen.url = 'http://example.com/307-3.xml'
      expect {
        loader.load!
      }.to raise_error(OpenMensa::FeedLoader::FeedLoadError)
    end

    it 'should follow update canteen URL on permanent redirect' do
      canteen.url = 'http://example.com/301.xml'
      loader.load!

      canteen.url.should == 'http://example.com/data.xml'
    end

    it 'should follow update canteen today URL on permanent redirect' do
      canteen.today_url = 'http://example.com/301.xml'
      today_loader.load!

      canteen.today_url.should == 'http://example.com/data.xml'
    end

    it 'should raise an error on 500' do
      canteen.url = 'http://example.com/500.xml'
      expect {
        loader.load!
      }.to raise_error(OpenMensa::FeedLoader::FeedLoadError)
    end

    it 'should raise an error on socket error' do
      canteen.url = 'http://unknowndomain.org/'
      expect {
        loader.load!
      }.to raise_error(OpenMensa::FeedLoader::FeedLoadError)
    end

    it 'should raise an error on timeout' do
      canteen.url = 'http://example.org/timeout.xml'
      expect {
        loader.load!
      }.to raise_error(OpenMensa::FeedLoader::FeedLoadError)
    end
  end
end
