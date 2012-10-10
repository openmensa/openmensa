class ApiController < BaseController
  include ActiveSupport::Inflector
  self.responder = OpenMensa::ApiResponder

  rescue_from ::CanCan::AccessDenied,         :with => :error_access_denied
  rescue_from ::ActiveRecord::RecordNotFound, :with => :error_not_found

  before_filter :setup_request

  attr_reader :current_client

  class << self
    attr_accessor :max_limit, :default_limit, :default_page
  end

  # **** api responders ****

  def decorate(collection_or_resource)
    constantize(controller_name.singularize.capitalize + 'Decorator').decorate(collection_or_resource)
  rescue NameError
    collection_or_resource
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

  def find_resource
    constantize(controller_name.singularize.capitalize).find params[:id]
  end

  def find_collection
    collection = constantize(controller_name.singularize.capitalize).scoped
    collection = apply_scopes(collection) if respond_to? :apply_scopes
    collection
  end

  # **** default api actions ****

  def index
    respond_with self.collection
  end

  def show
    respond_with self.resource
  end

  # **** setup ****

  def setup_request
    set_content_type
  end

  def set_content_type
    if ['json', 'xml', 'msgpack'].include? params[:format].to_s
      response.content_type = {
        json: 'application/json',
        xml: 'application/xml',
        msgpack: 'application/x-msgpack'
      }[params[:format].to_s.to_sym]
    else
      render_error status: :not_acceptable, message: 'Unsupported format.'
      false
    end
  end

  def set_api_version(version)
    custom_headers api_version: version
  end

  # **** errors *****

  def error_access_denied
    error status: :unauthorized
  end

  def error_not_found
    error status: :not_found
  end

  # **** header helpers ****

  def custom_headers(options)
    options ||= {}
    options.each do |key, value|
      key = key.to_s.camelize.gsub(/[^A-z]+/, '').gsub(/([A-Z])/, '-\1')
      response.headers["X-OM#{key}"] = value.to_s
    end
  end

  def self.api_version(value)
    before_filter do
      set_api_version value
    end
  end
end
