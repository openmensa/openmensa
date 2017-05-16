class AddDeveloperFlagToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :developer, :boolean, default: false
  end
end
