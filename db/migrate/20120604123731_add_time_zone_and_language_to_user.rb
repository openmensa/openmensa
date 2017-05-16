class AddTimeZoneAndLanguageToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :time_zone, :string
    add_column :users, :language,  :string, limit: 2
  end
end
