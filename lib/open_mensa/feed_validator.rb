# frozen_string_literal: true

module OpenMensa
  # The OpenMensa validator provide methods to validate feed
  # XML input again the OpenMense canteen feed scheme version
  # one or two. It also allows to auto detect used feed version.
  #
  # === Example
  #
  #   FeedValidator.new(document).valid?    # => false
  #   FeedValidator.new(document).validate! # raises Exception
  #   FeedValidator.new(document).version   # => 1
  #
  #   FeedValidator.new(document, version: 1) # force scheme version
  #
  class FeedValidator
    attr_reader :options, :errors, :document

    # A ValidationError will be raised if validation fails, scheme cannot be
    # loaded or document version cannot be determined.
    #
    # A ValidationError can contain an array of errors as produced by Nokogiri.
    #
    class FeedValidationError < ::StandardError
      attr_reader :errors

      def initialize(msg, errors = [])
        super(msg)
        @errors = errors
      end
    end

    # An InvalidFeedVersionError will be raised if feed version of passed document
    # cannot be determined.
    #
    class InvalidFeedVersionError < ::StandardError; end

    # Initializes new FeedValidator. First argument must be a XML data.
    # Second option is an optional hash of options. Available options are:
    #
    # * <tt>:version</tt> - Forces validator to use specified scheme version.
    #
    def initialize(document, options = {})
      @options  = options
      @document = document

      @required_main_version = @options[:version]
    end

    # Which version has the processed xml
    # String (1.0, 2.0, 2.1 ...)
    #
    def version
      @version ||= detect_version
    end

    # Check if XML is valid for OpenMensa scheme. Will test for all versions
    # unless a version was specified in constructor.
    #
    def valid?
      errors.empty? if validated?
      validate
    end

    # Validates document using specified or detect scheme. Will raise an
    # error if validation fails. Raised error will contain an array of
    # Nokogiri validation errors:
    #
    #   begin
    #     validator.validate!
    #   rescue ValidationError => e
    #     e.errors # => Array
    #   end
    #
    # Will return detected feed version.
    #
    def validate!
      @errors = schema.validate(document).to_a
      raise FeedValidationError.new("Error while validating document.", errors) unless errors.empty?

      version.to_i
    end

    # Validates document using specified or detect scheme. Will return
    # true on success false otherwise.
    #
    # If validation fails an array of Nokogiri errors can be accessed
    # via `#errors`.
    #
    def validate
      validate!
    rescue FeedValidationError, InvalidFeedVersionError
      false
    end

    # Check if document was already validated.
    #
    def validated?
      !errors.nil?
    end

    # Return specified or detected OpenMensa feed schema as an
    # Nokogiri XML schema.
    #
    def schema
      @schema ||= load_schema version
    end

    private

    def detect_version
      version = (document.root.nil? ? nil : document.root[:version])
      if @required_main_version && version && version.to_i != @required_main_version
        raise InvalidFeedVersionError.new("Document version #{version} does not match #{@required_main_version}")
      end
      if schema_file(version).nil?
        raise InvalidFeedVersionError.new("Cannot detect schema version.")
      else
        @version = version
      end
    end

    def load_schema(version)
      ::Nokogiri::XML::Schema.new File.open(schema_file(version))
    end

    def schema_file(version)
      case version.to_i
        when 1 then ::Rails.root.join("public", "open-mensa-v1.xsd").to_s
        when 2 then ::Rails.root.join("public", "open-mensa-v2.xsd").to_s
      end
    end
  end
end
