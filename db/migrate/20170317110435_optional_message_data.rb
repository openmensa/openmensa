# frozen_string_literal: true

class OptionalMessageData < ActiveRecord::Migration[4.2]
  def change
    change_column :messages, :data, :text, null: true
  end
end
