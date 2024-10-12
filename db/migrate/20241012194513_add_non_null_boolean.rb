# frozen_string_literal: true

class AddNonNullBoolean < ActiveRecord::Migration[7.2]
  def change
    change_column_null :canteens, :availibility, false, true
    change_column_null :days, :closed, false, false

    change_table :users, bulk: true do |t|
      t.change_null :admin, false, false
      t.change_null :developer, false, false
    end
  end
end
