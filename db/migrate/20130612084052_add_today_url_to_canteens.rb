class AddTodayUrlToCanteens < ActiveRecord::Migration
  def change
    add_column :canteens, :today_url, :string
  end
end
