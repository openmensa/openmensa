class AddReplacedByToCanteens < ActiveRecord::Migration[5.1]
  def change
    add_column :canteens, :replaced_by, :integer, null: true
  end
end
