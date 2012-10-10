class CanteenDecorator < Draper::Base
  decorates :canteen

  def coordinates
    [ latitude, longitude ]
  end
end
