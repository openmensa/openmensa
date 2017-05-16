class AddCategoryToMeals < ActiveRecord::Migration[4.2]
  def change
    add_column :meals, :category, :string
  end
end
