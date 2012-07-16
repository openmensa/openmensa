class RenameCafeteriaIdToCanteenId < ActiveRecord::Migration
  def change
    rename_column :meals, :cafeteria_id, :canteen_id
  end
end
