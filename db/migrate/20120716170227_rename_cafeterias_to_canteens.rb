class RenameCafeteriasToCanteens < ActiveRecord::Migration
  def change
    rename_table :cafeterias, :canteens
  end
end
