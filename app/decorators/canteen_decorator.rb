class CanteenDecorator < Draper::Base
  include ApiDecorator
  decorates :canteen

  api_attributes :id, :name, :address, :latitude, :longitude
  api_attributes :url, :user_id, if: Proc.new { h.current_user.admin? }

end
