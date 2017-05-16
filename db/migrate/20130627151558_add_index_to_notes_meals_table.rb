class AddIndexToNotesMealsTable < ActiveRecord::Migration[4.2]
  def change
    add_index :meals_notes, :meal_id
  end
end
