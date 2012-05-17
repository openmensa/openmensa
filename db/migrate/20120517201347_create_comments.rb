class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :message
      t.references :user
      t.references :commentee, polymorphic: true

      t.timestamps
    end
    add_index :comments, :user_id
    add_index :comments, :commentee_id
  end
end
