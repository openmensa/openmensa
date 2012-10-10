class Api::V2::CanteensController < ApiController
  self.responder = OpenMensa::ApiResponder

  respond_to :json

  has_scope :near, using: [ :lat, :lng, :dist ] do |controller, scope, value|
    lat = value[0].to_f
    lng = value[1].to_f

    if lat and lng
      scope.near([ lat, lng ], value[2] ? value[2].to_f : 10, units: :km)
    else
      scope
    end
  end

  has_scope :ids do |controller, scope, value|
    ids = value.split(',').map(&:to_i).select{|x| x > 0}.uniq
    scope.where(id: ids)
  end

  def find_collection
    super.order(:id)
  end
end
