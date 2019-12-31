# frozen_string_literal: true

class CreateOauth2Models < ActiveRecord::Migration[4.2]
  def change
    create_table :oauth2_access_tokens do |t|
      t.references :user
      t.references :client
      t.references :refresh_token
      t.string :token
      t.datetime :expires_at
      t.timestamps
    end

    create_table :oauth2_authorization_codes do |t|
      t.references :user
      t.references :client
      t.string :token
      t.string :redirect_uri
      t.datetime :expires_at
      t.timestamps
    end

    create_table :oauth2_clients do |t|
      t.references :user
      t.string :identifier
      t.string :secret
      t.string :name
      t.string :website
      t.string :redirect_uri
      t.timestamps
    end

    create_table :oauth2_refresh_tokens do |t|
      t.references :user
      t.references :client
      t.string :token
      t.datetime :expires_at
      t.timestamps
    end
  end
end
