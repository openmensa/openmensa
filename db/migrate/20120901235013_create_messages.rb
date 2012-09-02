class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.references :canteen
      t.string :type,         null: false
      t.string :priority,     null: false
      t.text :data,           null: false

      t.timestamps
    end
    add_index :messages, :canteen_id
    add_index :messages, :type
  end
end
