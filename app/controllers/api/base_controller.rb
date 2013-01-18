class Api::BaseController < ApiController
  responders OpenMensa::Responders::ApiResponder,
    OpenMensa::Responders::DecoratorResponder,
    Responders::PaginateResponder

  api_version 2

  class << self
    attr_accessor :max_limit, :default_limit, :default_page
  end

  # **** api responders ****

  before_filter :setup_collection, only: :index
  before_filter :setup_resource, only: [ :show, :update, :destroy ]

  def setup_collection; self.collection = find_collection; end
  def setup_resource; self.resource = find_resource; end

  def decorate(resource)
    if resource.is_a?(ActiveRecord::Relation)
      self.collection = self.class.decorator_class.decorate_collection(resource)
    else
      self.resource = self.class.decorator_class.decorate(resource)
    end
  rescue NameError
    resource
  end

  def resource=(resource)
    instance_variable_set "@#{controller_name.singularize}", resource
  end

  def collection=(collection)
    instance_variable_set "@#{controller_name}", collection
  end

  def resource
    resource = instance_variable_get "@#{controller_name.singularize}"
    resource ||= self.resource = find_resource
  end

  def collection
    collection = instance_variable_get "@#{controller_name}"
    collection ||= self.collection = find_collection
  end

  def default_scope(scope)
    scope
  end

  def scoped_resource
    default_scope(self.class.resource_class.scoped)
  end

  def find_resource
    scoped_resource.find params[:id]
  end

  def find_collection
    collection = default_scope(self.class.resource_class.scoped)
    collection = apply_scopes(collection) if respond_to? :apply_scopes
    collection
  end

  def self.resource_name
    @resource_name ||= controller_name.singularize.capitalize
  end

  def self.resource_class
    @resource_class ||= ActiveSupport::Inflector.constantize resource_name
  end

  def self.decorator_class
    @decorator_class ||= ActiveSupport::Inflector.constantize(resource_name + 'Decorator')
  end

  # **** default api actions ****

  def index
    respond_with self.collection
  end

  def show
    respond_with self.resource
  end

  # paginate reponder methods

  def max_per_page
    100
  end

  def per_page
    params[:per_page] || params[:limit] || 50
  end
end
