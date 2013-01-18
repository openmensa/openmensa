class OpenMensa::ApiResponder < ActionController::Responder
  include Responders::HttpCacheResponder
  include OpenMensa::Responders::DecoratorResponder
  include Responders::PaginateResponder
end
