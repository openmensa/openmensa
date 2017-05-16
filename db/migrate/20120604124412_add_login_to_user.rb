class AddLoginToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :login, :string
  end
end
