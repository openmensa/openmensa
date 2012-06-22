class ApiController < BaseController
  rescue_from ::CanCan::AccessDenied,         :with => :error_access_denied
  rescue_from ::ActiveRecord::RecordNotFound, :with => :error_not_found

  before_filter :set_content_type, :check_authentication

  attr_reader :current_client

  # **** setup ****

  def set_content_type
    if ['json', 'xml', 'msgpack'].include? params[:format].to_s
      response.content_type = "application/#{params[:format]}"
    else
      render_error status: :not_acceptable, message: 'Unsupported format.'
      false
    end
  end

  def check_authentication
    if current_access_token
      self.current_user = current_access_token.user
      @current_client   = current_access_token.client
    end
  end

  def setup_ability
    current_access_token.try(:ability) || current_user.ability
  end

  # **** accessors ****

  def current_access_token
    @access_token ||= request.env[Rack::OAuth2::Server::Resource::ACCESS_TOKEN]
  end

  # **** errors *****

  def error_access_denied
    error status: :unauthorized
  end

  def error_not_found
    error status: :not_found
  end
end
