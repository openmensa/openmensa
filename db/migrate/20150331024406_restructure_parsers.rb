class RestructureParsers < ActiveRecord::Migration
  def change
    create_table :parsers do |t|
      t.references :user
      t.string :name, null: false
      t.string :version, null: true
      t.string :info_url, null: true
      t.string :index_url, null: true

      t.datetime :last_report_at, null: true

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
      t.datetime :last_fetched_at, null: true
      t.datetime :next_fetch_at, null: true

      t.timestamps
    end
    add_index :feeds, [:source_id, :name], unique: true

    create_table :data_proposals do |t|
      t.references :canteen
      t.references :user
      t.string :state, default: 'new', null: false
      t.string :name
      t.string :city
      t.string :address
      t.float :longitude
      t.float :latitude
      t.string :phone
      t.string :email
      t.string :availibility
      t.string :openingTimes, array: true

      t.timestamps
    end

    create_table :error_reports do |t|
      t.references :canteen
      t.references :user
      t.string :state, default: 'new', null: false
      t.text :message

      t.timestamps
    end

    create_table :feed_fetches do |t|
      t.references :feed
      t.string :state, null: false
      t.string :reason, null: false
      t.string :version, null: true
      t.integer :added_days
      t.integer :updated_days
      t.integer :added_meals
      t.integer :updated_meals
      t.integer :removed_meals

      t.datetime :executed_at, null: false
    end

    change_table :canteens do |t|
      t.string :state, null: false, default: 'wanted'
      t.string :phone
      t.string :email
      t.boolean :availibility, default: true
      t.string :openingTimes, array: true
    end

    change_table :messages do |t|
      t.references :messageable, polymorphic: true, index: true
    end

    reversible do |dir|
      dir.up do
        say_with_time 'migration data' do
          Canteen.transaction do
            Canteen.reset_column_information
            Canteen.all.each do |c|
              next unless c.url.present?
              parserName = c.url[0..c.url.rindex('/')-1]
              p = Parser.find_or_create_by!(name: parserName, user_id: c.user_id)
              name = c.url[(c.url.rindex('/')+1)..400]
              if name =~ /^([^.]+)\.[^.]+$/
                name = $1
              end
              s = Source.create! parser: p,
                                 name: name,
                                 canteen: c
              feed = Feed.create! name: 'full',
                           source: s,
                           url: c.url,
                           schedule: '0 8 * * *',
                           retry: '60 6',
                           priority: 0
              Message.where(canteen_id: c.id).update_all(messageable_id: feed.id, messageable_type: 'Feed')
              if c.today_url.present?
                Feed.create! name: 'today',
                             source: s,
                             url: c.today_url,
                             schedule: '0 8-14 * * *',
                             priority: 10
              end
              c.url = nil
              c.today_url = nil
              c.state = 'working'
              c.save!
            end
          end
        end
        change_table :canteens do |t|
          t.remove :url, :today_url, :fetch_hour, :user_id
        end
      end

      dir.down do
        say_with_time 'migration data' do
          change_table :canteens do |t|
            t.string :url
            t.string :today_url, null: true
            t.integer :fetch_hour
            t.references :user
          end
          Canteen.reset_column_information
          Canteen.transaction do
            Canteen.all.each do |c|
              s = c.sources.first
              next if s.nil?
              s.feeds.each do |f|
                if f.name == 'full'
                  c.url = f.url
                elsif f.name == 'today'
                  c.today_url = f.url
                end
              end
              c.user_id = s.parser.user_id
              c.save!
            end
          end
        end
      end
    end
  end
end
