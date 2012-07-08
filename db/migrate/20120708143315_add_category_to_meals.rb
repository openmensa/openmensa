class AddCategoryToMeals < ActiveRecord::Migration
  def change
    add_column :meals, :category, :string
  end
end
