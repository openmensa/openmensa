
collection @cafeterias
attributes :id, :name, :address
node(:meals) do |cafeteria|
  partial("api/v1/meals/index", object: cafeteria.meals.where('date <= ?', (Time.zone.now + 1.days).to_date))
end
