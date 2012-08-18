class AddDeveloperFlagToUser < ActiveRecord::Migration
  def change
    add_column :users, :developer, :boolean, default: false
  end
end
