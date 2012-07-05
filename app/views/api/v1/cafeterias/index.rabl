
collection @cafeterias
attributes :id, :name, :address

node(:meals) do |cafeteria|
  partial("api/v1/meals/index", object: cafeteria.meals.where('date < ? AND date >= ?', (Time.zone.now + 2.day).to_date, (Time.zone.now - 1.day).to_date))
end
