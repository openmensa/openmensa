module OpenMensa
  module Responders
    module DecoratorResponder
      def to_format
        if resource.respond_to? :decorate
          @resource = resource.decorate
        end
        super
      end
    end
  end
end
