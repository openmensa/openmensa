# frozen_string_literal: true

class ConvertMessagesDataToJsonb < ActiveRecord::Migration[7.1]
  def change
    add_column :messages, :payload, :jsonb, null: false, default: {}

    reversible do |dir|
      dir.up do
        message = Class.new(ActiveRecord::Base)
        message.table_name = "messages"
        message.inheritance_column = :_type_disabled

        message.find_each(batch_size: 10_000) do |msg|
          data = YAML.load(msg.data.to_s)&.stringify_keys
          msg.payload = data || {}
          msg.save!(touch: false)
        end
      end
    end

    remove_column :messages, :data, :string
  end
end
