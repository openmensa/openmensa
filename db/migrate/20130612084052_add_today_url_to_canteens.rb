# frozen_string_literal: true

class AddTodayUrlToCanteens < ActiveRecord::Migration[4.2]
  def change
    add_column :canteens, :today_url, :string
  end
end
