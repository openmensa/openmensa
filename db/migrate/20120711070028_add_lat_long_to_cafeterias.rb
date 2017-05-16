class AddLatLongToCafeterias < ActiveRecord::Migration[4.2]
  def change
    add_column :cafeterias, :longitude, :float
    add_column :cafeterias, :latitude, :float
  end
end
