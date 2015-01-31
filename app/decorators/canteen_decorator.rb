class CanteenDecorator < Draper::Decorator
  include ApiResponder::Formattable
  decorates :canteen

  def coordinates
    return nil if model.latitude.nil? or model.longitude.nil?
    [ model.latitude, model.longitude ]
  end

  def as_api_v1(options)
    {
      cafeteria: {
        id: model.id,
        name: model.name,
        address: model.address,
        meals: model.meals.where('date < ? AND date >= ?', (Time.zone.now + 2.day).to_date, Time.zone.now.to_date).decorate
      }
    }
  end

  def as_api_v2(options)
    {
      id: model.id,
      name: model.name,
      city: model.city,
      address: model.address,
      coordinates: coordinates
    }
  end
end
