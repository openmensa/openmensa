class AddPositionToMeals < ActiveRecord::Migration
  def change
    add_column :meals, :pos, :integer
  end
end
