
object false
child(@meal) do
  attributes :id, :name, :description
  node(:date) { |object| object.date.to_time.iso8601 }
end
