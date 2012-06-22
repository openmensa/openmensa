class Api::V1::StatusController < Api::V1::BaseController

  def index
    @env = request.env
    render template: 'api/v1/status'
  end
end
