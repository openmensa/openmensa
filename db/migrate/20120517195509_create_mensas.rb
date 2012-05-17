class CreateMensas < ActiveRecord::Migration
  def change
    create_table :mensas do |t|
      t.string :name
      t.string :address
      t.string :url
      t.references :user

      t.timestamps
    end
    add_index :mensas, :user_id
  end
end
