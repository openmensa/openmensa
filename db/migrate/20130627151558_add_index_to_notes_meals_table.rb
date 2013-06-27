class AddIndexToNotesMealsTable < ActiveRecord::Migration
  def change
    add_index :meals_notes, :meal_id
  end
end
