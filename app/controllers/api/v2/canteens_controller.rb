class Api::V2::CanteensController < ApiController
  inherit_resources
  actions :index, :show
  include OpenMensa::ResourceDecorator

  respond_to :json

  has_scope :limit, default: 100 do |controller, scope, value|
    scope.limit [[1, value.to_i].max, 100].min
  end

  has_scope :near, using: [ :lat, :lng, :dist ] do |controller, scope, value|
    lat = value[0].to_f
    lng = value[1].to_f

    if lat and lng
      scope.near([ lat, lng ], value[2] ? value[2].to_f : 10, units: :km)
    else
      scope
    end
  end
end
