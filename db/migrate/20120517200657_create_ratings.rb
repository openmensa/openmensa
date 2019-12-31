# frozen_string_literal: true

class CreateRatings < ActiveRecord::Migration[4.2]
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
