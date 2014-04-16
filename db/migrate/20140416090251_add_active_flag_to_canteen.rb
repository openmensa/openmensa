class AddActiveFlagToCanteen < ActiveRecord::Migration
  def change
    add_column :canteens, :active, :boolean, default: true
  end
end
