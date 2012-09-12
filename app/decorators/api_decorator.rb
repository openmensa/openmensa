module ApiDecorator

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def api_attributes(*attrs)
      options = attrs.extract_options!
      @api_attributes ||= []
      @api_attributes << [ attrs, options ]
    end

    def api_attribute_list(model, options)
      names = []
      @api_attributes.each do |attrs, opts|
        next if opts[:format] and opts[:format] != options[:format]
        next if opts[:formats] and not opts[:formats].include? options[:format]
        next if opts[:if] and not opts[:if].call model, options
        next if opts[:unless] and not opts[:unless].call model, options

        names += attrs
      end
      names.uniq
    end
  end

  def as_api(options)
    self.class.api_attribute_list(model, options).inject({}) { |memo, name| memo[name] = send name; memo }
  end

  def as_json(options)
    as_api(options.merge format: :json).as_json
  end

  def to_json(options)
    as_json(options).to_json
  end

  def to_xml(options)
    as_api(options.merge format: :xml).to_xml
  end

  def to_mpac(options)
    as_api(options.merge format: :mpac).as_mpac
  end
end
