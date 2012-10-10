module OpenMensa
  module Responders
    module PaginateResponder
      def to_format
        if get? && resource.is_a?(ActiveRecord::Relation)
          @resource = resource.paginate page: self.page, per_page: self.limit
          controller.collection = @resource if controller.respond_to? :collection=
        end
        super
      end

      def page
        @page ||= controller.params[:page].try(:to_i) || controller_property(:default_page, 1)
      rescue
        1
      end

      def limit
        return @limit if @limit
        @limit ||= controller.params[:limit].try(:to_i) || controller_property(:default_limit, 10)
        @limit = [[1, @limit].max, controller_property(:max_limit, 100)].min
      end

      def controller_property(name, default = nil)
        property = controller.send name if controller.respond_to? name
        property ||= controller.class.send name if controller.class.respond_to? name
        property || default
      end
    end
  end
end
