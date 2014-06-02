class Api::V2::CanteensController < Api::BaseController
  respond_to :json

  has_scope :near, using: [ :lat, :lng, :dist, :place ] do |controller, scope, value|
    place = if value[3]
      value[3].to_s
    else
      [ value[0].to_f, value[1].to_f ]
    end

    if place
      scope.reorder('').near(place, value[2] ? value[2].to_f : 10, units: :km, order_by_without_select: :distance)
    else
      scope
    end
  end

  has_scope :ids do |controller, scope, value|
    ids = value.split(',').map(&:to_i).select{|x| x > 0}.uniq
    scope.where(id: ids)
  end

  def find_collection
    apply_scopes Canteen.all.order(:id)
  end
end
