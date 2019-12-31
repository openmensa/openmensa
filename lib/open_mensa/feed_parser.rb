# frozen_string_literal: true

require 'nokogiri'

module OpenMensa
  # FeedParser provide methods to parse XML input into an Nokogiri
  # XML document. There will be no validation or semantic check done.
  #
  # === Example
  #
  #   FeedParser.new(document).parse! # => Nokogiri::XML::Document
  #
  class FeedParser
    attr_reader :data, :errors, :document

    # A ParserError will be raised when given data is no valid XML.
    # An array of Nokogiri errors can be accessed via `#errors`.
    class ParserError < StandardError
      attr_reader :errors

      def initialize(msg, errors = [])
        super(msg)
        @errors = errors
      end
    end

    # Creates new FeedParser. First argument must be data that should
    # be parsed.
    #
    def initialize(data)
      @data = data
    end

    # Parses data. Will return parsed XML document or raise a
    # a ParserError if data is invalid.
    #
    def parse!
      @document = ::Nokogiri::XML::Document.parse(data).tap do |doc|
        @errors = doc.errors
        raise ParserError.new('Error while parsing feed data.', errors) unless errors.empty?
      end
    end

    # Parses data. Will return parsed XML document or false on error.
    #
    def parse
      parse!
    rescue ParserError => e
      false
    end
  end
end
