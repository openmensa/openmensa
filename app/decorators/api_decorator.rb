module ApiDecorator

  # class UnsupportedVersionError < Error; end

  def self.included(base)
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods
  end

  module InstanceMethods
    def as_json(options = {})
      as_api(options.merge(format: :json)).as_json(options)
    end

    def as_api(options)
      method = :"to_version_#{options[:api].try(:[], :version) || self.class.api_versions.last}"

      if respond_to? method
        return send(method, options)
      end

      # raise UnsupportedVersionError.new
    end
  end

  module ClassMethods
    def api_versions(*attrs)
      @_api_versions ||= []
      return @_api_versions unless attrs

      attrs.map!(&:to_a)
      @_api_versions << attrs
      @_api_versions.uniq!
      @_api_versions
    end
  end
end
