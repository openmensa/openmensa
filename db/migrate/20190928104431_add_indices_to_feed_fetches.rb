# frozen_string_literal: true

class AddIndicesToFeedFetches < ActiveRecord::Migration[5.2]
  def change
    change_table :feed_fetches do |t|
      t.index :feed_id
      t.index :executed_at
    end
  end
end
