# frozen_string_literal: true

class AddLatLongToCafeterias < ActiveRecord::Migration[4.2]
  def change
    change_table :cafeterias, bulk: true do |t|
      t.float :longitude
      t.float :latitude
    end
  end
end
