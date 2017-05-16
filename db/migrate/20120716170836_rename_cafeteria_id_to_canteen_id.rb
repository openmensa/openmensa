class RenameCafeteriaIdToCanteenId < ActiveRecord::Migration[4.2]
  def change
    rename_column :meals, :cafeteria_id, :canteen_id
  end
end
