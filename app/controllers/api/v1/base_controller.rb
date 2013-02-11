class Api::V1::BaseController < ApiController
  api_version 1
  responders Responders::ApiResponder,
    Responders::DecorateResponder

  respond_to :json
end
