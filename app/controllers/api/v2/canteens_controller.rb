# frozen_string_literal: true

class Api::V2::CanteensController < Api::BaseController
  respond_to :json

  has_scope :near, using: %i[lat lng dist place] do |_controller, scope, value|
    place = if value[3]
              value[3].to_s
            else
              [value[0].to_f, value[1].to_f]
            end

    if place
      scope.reorder("").near(
        place,
        value[2] ? value[2].to_f : 10,
        units: :km,
        order_by_without_select: :distance
      )
    else
      scope
    end
  end

  has_scope :ids do |_controller, scope, value|
    ids = value.split(",").map(&:to_i).select(&:positive?).uniq
    scope.where(id: ids)
  end

  has_scope :hasCoordinates do |_controller, scope, value|
    if value != "false" && value != "0" && value
      scope.where("latitude IS NOT NULL and longitude IS NOT NULL")
    else
      scope.where("latitude IS NULL and longitude IS NULL")
    end
  end

  def find_collection
    apply_scopes Canteen.active.order(:id)
  end

  def find_resource
    canteen = super
    if canteen.replaced?
      canteen.replaced_by
    else
      canteen
    end
  end
end
