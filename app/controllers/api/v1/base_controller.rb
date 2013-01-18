class Api::V1::BaseController < ApiController
  api_version 1
  responders OpenMensa::Responders::ApiResponder,
    OpenMensa::Responders::DecoratorResponder
  respond_to :json

  def decorate(resource)
    if resource.is_a?(ActiveRecord::Relation)
      self.class.decorator_class.decorate_collection(resource)
    else
      self.class.decorator_class.decorate(resource)
    end
  rescue NameError
    resource
  end
end
