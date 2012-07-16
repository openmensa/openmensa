
object false
child(@canteen => "cafeteria") do
  attributes :id, :name, :address

  node(:meals) do |canteen|
    partial("api/v1/cafeterias/meals", object: canteen.meals.where('date < ? AND date >= ?', (Time.zone.now + 2.day).to_date, Time.zone.now.to_date))
  end
end
