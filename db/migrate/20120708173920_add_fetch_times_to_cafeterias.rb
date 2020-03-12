# frozen_string_literal: true

class AddFetchTimesToCafeterias < ActiveRecord::Migration[4.2]
  def change
    change_table :cafeterias, bulk: true do |t|
      t.datetime :last_fetched_at
      t.integer :fetch_hour
    end
  end
end
