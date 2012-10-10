class OpenMensa::ApiResponder < ActionController::Responder
  include OpenMensa::Responders::DecoratorResponder
  include OpenMensa::Responders::PaginateResponder
  include Responders::HttpCacheResponder
end
