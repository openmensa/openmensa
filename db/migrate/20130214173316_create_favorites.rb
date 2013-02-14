class CreateFavorites < ActiveRecord::Migration
  def change
    create_table :favorites do |t|
      t.references :canteen
      t.references :user
      t.integer :priority

      t.timestamps
    end
  end
end
