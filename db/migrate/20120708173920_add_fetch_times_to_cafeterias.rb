class AddFetchTimesToCafeterias < ActiveRecord::Migration[4.2]
  def change
    add_column :cafeterias, :last_fetched_at, :datetime
    add_column :cafeterias, :fetch_hour, :integer
  end
end
