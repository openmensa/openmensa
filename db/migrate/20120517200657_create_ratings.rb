class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.datetime :date
      t.integer :value
      t.references :meal
      t.references :user

      t.timestamps
    end
    add_index :ratings, :meal_id
    add_index :ratings, :user_id
  end
end
