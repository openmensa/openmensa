class Api::V2::CanteensController < ApiController
  respond_to :json

  def index
    limit = params[:limit] ? [params[:limit].to_i, 100].min : 100

    respond_with CanteenDecorator.decorate Canteen.limit(limit)
  end
end
