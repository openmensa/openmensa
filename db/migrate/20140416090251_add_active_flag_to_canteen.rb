class AddActiveFlagToCanteen < ActiveRecord::Migration[4.2]
  def change
    add_column :canteens, :active, :boolean, default: true
  end
end
