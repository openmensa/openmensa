# frozen_string_literal: true

class AddUniqueLogin < ActiveRecord::Migration[8.0]
  def change
    add_index :users, :login, unique: true
  end
end
