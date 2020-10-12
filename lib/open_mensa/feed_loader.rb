# frozen_string_literal: true

module OpenMensa
  # The FeedLoader provides methods to load ad parse a canteen feed from
  # it's URL. It handles HTTP responses and redirects.
  #
  # === Example
  #
  #   FeedLoader.new(@canteen).load! # => String
  #
  class FeedLoader
    attr_reader :resource, :url_field, :data, :error, :options

    # A FeedLoadError will be raised if canteen feed cannot be loaded due
    # unavailability of feed or illegal response. FeedLoadError contains
    # an `cause` attribute containing the responsible low level error.
    #
    class FeedLoadError < StandardError
      attr_reader :cause

      def initialize(msg, cause = nil)
        @cause = cause
        msg += " Caused by #{cause.class.name}: #{cause.message}" if @cause
        super msg
      end
    end

    # Creates new FeedLoader for given canteen. First arguments must be a
    # Canteen, second can be an option hash. Available options are
    #
    # * <tt>:follow</tt> - If true FeedLoader will follow redirects.
    # * <tt>:depth</tt>  - Maximum number of redirects to follow.
    # * <tt>:update</tt> - If true canteen URL will be updated on a permanent redirect.
    #
    def initialize(resource, url_field, options = {})
      @options = options.reverse_merge self.class.default_options
      @resource = resource
      @url_field = url_field
    end

    # Loads feed data from canteens URL. Will raise a FeedLoadError if an error
    # occurs. Returns loaded data as StringIO on success.
    #
    def load!
      return nil if url.blank?

      load_feed @options[:follow] ? @options[:depth] : 0
    rescue URI::InvalidURIError => e
      raise FeedLoadError.new("Invalid URL (#{url}) for #{resource}.", e)
    rescue StandardError => e
      raise FeedLoadError.new("Error while loading feed.", e)
    end

    class << self
      # Returns default options for new FeedLoaders.
      #
      def default_options
        {
          follow: true,
          update: true,
          depth: 2
        }
      end
    end

    def url
      resource.send url_field
    end

    def uri
      @uri ||= URI.parse url
    end

    private

    def load_feed(allowed_redirects, uri = self.uri)
      uri.open(redirect: false)
    rescue OpenURI::HTTPRedirect => e
      if !options[:follow] || allowed_redirects <= 0
        raise FeedLoadError.new("Too much redirects.", e)
      end

      if options[:update] && e.message.start_with?("301")
        update_url e.uri.to_s
      end # permanent redirect

      load_feed allowed_redirects - 1, e.uri
    end

    def update_url(new_url)
      Rails.logger.warn "Update URL of #{resource} to '#{new_url}'."
      FeedUrlUpdatedInfo.create messageable: resource, old_url: url, new_url: new_url

      resource.update! url_field => new_url
    end
  end
end
