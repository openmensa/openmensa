class Api::V1::StatusController < Api::V1::BaseController

  def index
    @env = request.env
    render template: 'api/status'
  end
end
