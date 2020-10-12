# frozen_string_literal: true

class Api::BaseController < ApiController
  responders Responders::ApiResponder,
    Responders::DecorateResponder,
    Responders::PaginateResponder

  api_version 2

  # **** api responders ****

  def resource
    @resource ||= find_resource
  end

  def collection
    @collection ||= find_collection
  end

  def default_scope(scope)
    scope
  end

  def scoped_resource
    default_scope(self.class.resource_class.all)
  end

  def find_resource
    scoped_resource.find params[:id]
  end

  def find_collection
    apply_scopes default_scope(self.class.resource_class.all)
  end

  def self.resource_name
    @resource_name ||= controller_name.singularize.capitalize
  end

  def self.resource_class
    @resource_class ||= ActiveSupport::Inflector.constantize resource_name
  end

  def self.decorator_class
    @decorator_class ||= \
      ActiveSupport::Inflector.constantize("#{resource_name}Decorator")
  end

  # **** default api actions ****

  def index
    respond_with collection
  end

  def show
    respond_with resource
  end

  # paginate reponder methods

  def max_per_page
    100
  end

  def per_page
    params[:per_page].try(:to_i) || params[:limit].try(:to_i) || 50
  end
end
