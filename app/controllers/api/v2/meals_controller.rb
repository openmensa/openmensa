class Api::V2::MealsController < ApiController
  inherit_resources
  actions :index
  belongs_to :canteen
  include OpenMensa::ResourceDecorator

  respond_to :json
end
