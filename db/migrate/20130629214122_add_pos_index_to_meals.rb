class AddPosIndexToMeals < ActiveRecord::Migration
  def change
    add_index :meals, :pos
  end
end
