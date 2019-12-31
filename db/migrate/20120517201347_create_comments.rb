# frozen_string_literal: true

class CreateComments < ActiveRecord::Migration[4.2]
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
