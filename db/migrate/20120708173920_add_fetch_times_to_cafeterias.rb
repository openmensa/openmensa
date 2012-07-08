class AddFetchTimesToCafeterias < ActiveRecord::Migration
  def change
    add_column :cafeterias, :last_fetched_at, :datetime
    add_column :cafeterias, :fetch_hour, :integer
  end
end
