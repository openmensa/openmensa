class RestructureParsers < ActiveRecord::Migration
  def change
    create_table :parsers do |t|
      t.references :user
      t.string :name, null: false
      t.string :version, null: true
      t.text :info_url, null: true

      t.timestamps
    end
    add_index :parsers, [:user_id, :name], unique: true

    create_table :sources do |t|
      t.references :canteen
      t.references :parser
      t.string :name, null: false
      t.string :meta_url

      t.timestamps
    end
    add_index :sources, [:canteen_id, :parser_id], unique: true
    add_index :sources, [:parser_id, :name], unique: true

    create_table :feeds do |t|
      t.references :source
      t.integer :priority, default: 0, null: false
      t.string :name, null: false
      t.string :url, null: false
      t.string :schedule, null: false
      t.string :retry
      t.string :source_url, null: true
      t.datetime :last_fetched_at

      t.timestamps
    end
    add_index :feeds, [:source_id, :name], unique: true
  end
end
