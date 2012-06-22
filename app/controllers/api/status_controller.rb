class Api::StatusController < ApiController

  def index
    @env = request.env
    render template: 'api/status'
  end
end
