module OpenMensa
  module Responders
    module ApiResponder
      def options
        super.merge(:api => api_options)
      end

      def api_options
        {
          :version => api_version
        }
      end

      def api_version
        @api_version ||= detect_api_version
        @api_version
      end

      def detect_api_version
        if request.path =~ /^\/api\/v(\d+)\//
          return $1.to_i
        end
      end
    end
  end
end
