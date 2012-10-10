module OpenMensa
  module Responders
    module DecoratorResponder
      def to_format
        if controller.respond_to? :decorate
          @resource = controller.decorate(resource)
          if resource.is_a?(ActiveRecord::Relation)
            controller.collection = @resource if controller.respond_to? :collection=
          else
            controller.resource = @resource if controller.respond_to? :resource=
          end
        end
        super
      end
    end
  end
end
