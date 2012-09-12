class CanteenDecorator < Draper::Base
  include ApiDecorator
  decorates :canteen
  api_attributes :id, :name, :address, :latitude, :longitude
end
