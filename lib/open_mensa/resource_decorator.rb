module OpenMensa
  module ResourceDecorator
    include ActiveSupport::Inflector

  protected
    def collection
      @cached_collection ||= decorate_resource_or_collection(end_of_association_chain)
    end

    def resource
      @cached_resource ||= decorate_resource_or_collection(super)
    end

  private
    def decorate_resource_or_collection(item_or_items)
      constantize(resource_class.name + "Decorator").decorate(item_or_items)
      rescue NameError
        item_or_items
    end
  end
end
