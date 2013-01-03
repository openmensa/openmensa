
collection @days
extends 'api/v2/days/show'
child(:meals) do
  extends 'api/v2/meals/show'
end
