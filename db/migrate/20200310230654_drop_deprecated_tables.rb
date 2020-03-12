# frozen_string_literal: true

class DropDeprecatedTables < ActiveRecord::Migration[6.0]
  def up
    drop_table :ratings
    drop_table :comments
    drop_table :oauth_access_grants
    drop_table :oauth_access_tokens
    drop_table :oauth_applications
  end
end
