
collection @meals, root: false, object_root: "meal"
attributes :id, :name, :description
node(:date) { |object| object.date.to_time.iso8601 }
