class AddLatLongToCafeterias < ActiveRecord::Migration
  def change
    add_column :cafeterias, :longitude, :float
    add_column :cafeterias, :latitude, :float
  end
end
