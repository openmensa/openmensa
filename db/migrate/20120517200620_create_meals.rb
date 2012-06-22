class CreateMeals < ActiveRecord::Migration
  def change
    create_table :meals do |t|
      t.string :name
      t.datetime :date
      t.string :description
      t.references :cafeteria

      t.timestamps
    end
    add_index :meals, :cafeteria_id
  end
end
