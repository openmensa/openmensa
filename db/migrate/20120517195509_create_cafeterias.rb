class CreateCafeterias < ActiveRecord::Migration[4.2]
  def change
    create_table :cafeterias do |t|
      t.string :name
      t.string :address
      t.string :url
      t.references :user

      t.timestamps
    end
    add_index :cafeterias, :user_id
  end
end
