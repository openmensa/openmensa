# frozen_string_literal: true

class AddTimeZoneAndLanguageToUser < ActiveRecord::Migration[4.2]
  def change
    change_table :users, bulk: true do |t|
      t.string :time_zone
      t.string :language, limit: 2
    end
  end
end
