
collection @canteens, root: false, object_root: "cafeteria"
attributes :id, :name, :address

node(:meals) do |canteen|
  partial("api/v1/meals/index", object: canteen.meals.where('date < ? AND date >= ?', (Time.zone.now + 2.day).to_date, Time.zone.now.to_date))
end

