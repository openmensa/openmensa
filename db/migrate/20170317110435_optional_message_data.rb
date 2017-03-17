class OptionalMessageData < ActiveRecord::Migration
  def change
    change_column :messages, :data, :text, null: true
  end
end
