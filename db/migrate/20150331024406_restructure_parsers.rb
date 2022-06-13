# frozen_string_literal: true

class RestructureParsers < ActiveRecord::Migration[4.2]
  def change
    create_table :parsers do |t|
      t.references :user
      t.string :name, null: false
      t.string :version, null: true
      t.string :info_url, null: true
      t.string :index_url, null: true
      t.boolean :maintainer_wanted, default: false, null: false

      t.datetime :last_report_at, null: true

      t.timestamps
    end
    add_index :parsers, %i[user_id name], unique: true

    create_table :sources do |t|
      t.references :canteen
      t.references :parser
      t.string :name, null: false
      t.string :meta_url

      t.timestamps
    end
    add_index :sources, %i[canteen_id parser_id], unique: true
    add_index :sources, %i[parser_id name], unique: true

    create_table :feeds do |t|
      t.references :source
      t.integer :priority, default: 0, null: false
      t.string :name, null: false
      t.string :url, null: false
      t.string :schedule, null: true
      t.integer :retry, array: true, null: true
      t.string :source_url, null: true
      t.datetime :last_fetched_at, null: true
      t.datetime :next_fetch_at, null: true
      t.integer :current_retry, array: true, null: true

      t.timestamps
    end
    add_index :feeds, %i[source_id name], unique: true

    create_table :data_proposals do |t|
      t.references :canteen
      t.references :user
      t.string :state, default: "new", null: false
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

    create_table :feedbacks do |t|
      t.references :canteen
      t.references :user
      t.string :state, default: "new", null: false
      t.text :message

      t.timestamps
    end

    create_table :feed_fetches do |t| # rubocop:disable Rails/CreateTableWithTimestamps
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

    change_table :canteens, bulk: true do |t|
      t.string :state, null: false, default: "wanted"
      t.string :phone
      t.string :email
      t.boolean :availibility, default: true
      t.string :openingTimes, array: true
    end

    change_table :messages do |t|
      t.references :messageable, polymorphic: true, index: true
    end

    change_table :users, bulk: true do |t|
      t.string :public_email, null: true
      t.string :public_name, null: true
      t.string :notify_email, null: true
      t.string :info_url, null: true
    end

    reversible do |dir|
      dir.up do
        say_with_time "migration data" do
          Canteen.transaction do
            Canteen.reset_column_information
            Canteen.all.each do |c|
              next if c.url.blank?

              parser_name = c.url[0..c.url.rindex("/") - 1]
              p = Parser.find_or_create_by!(name: parser_name, user_id: c.user_id)
              name = c.url[(c.url.rindex("/") + 1)..400]
              name = Regexp.last_match(1) if name =~ /^([^.]+)\.[^.]+$/
              s = Source.create! parser: p,
                name: name,
                canteen: c
              feed = Feed.create! name: "full",
                source: s,
                url: c.url,
                schedule: "0 8 * * *",
                retry: [60, 6],
                priority: 0
              Message.where(canteen_id: c.id).update_all(messageable_id: feed.id, messageable_type: "Feed")
              if c.today_url.present?
                Feed.create! name: "today",
                  source: s,
                  url: c.today_url,
                  schedule: "0 8-14 * * *",
                  priority: 10
              end
              c.url = nil
              c.today_url = nil
              c.state = c.active ? "active" : "archived"
              c.save!
            end
          end
        end
        change_table :canteens do |t|
          t.remove :url, :today_url, :fetch_hour, :user_id, :active
        end
      end

      dir.down do
        say_with_time "migration data" do
          change_table :canteens, bulk: true do |t|
            t.string :url
            t.string :today_url, null: true
            t.integer :fetch_hour
            t.boolean :active, default: false
            t.references :user
          end
          Canteen.reset_column_information
          Canteen.transaction do
            Canteen.all.each do |c|
              s = c.sources.first
              next if s.nil?

              s.feeds.each do |f|
                case f.name
                  when "full"
                    c.url = f.url
                  when "today"
                    c.today_url = f.url
                end
              end
              c.user_id = s.parser.user_id
              c.state = "active"
              c.active = c.state == "active"
              c.save!
            end
          end
        end
      end
    end
  end
end
