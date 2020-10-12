# frozen_string_literal: true

class CreateDayTable < ActiveRecord::Migration[4.2]
  class Meal < ActiveRecord::Base
  end
  def up
    # 1. add new entity
    create_table :days do |t|
      t.references :canteen
      t.date :date
      t.boolean :closed, default: false
      t.timestamps
    end
    change_table :meals do |t|
      t.references :day
    end

    # 2. migrate data
    say_with_time "updating meals" do
      Day.reset_column_information
      Meal.reset_column_information
      count = 0
      Meal.all.each do |m|
        canteen = Canteen.find_by id: m.canteen_id
        # way is this needed:
        unless canteen
          say "WARN: Meal without canteen: #{m}"
          m.destroy
          next
        end
        day = canteen.days.find_by date: m.read_attribute(:date)
        day ||= canteen.days.create date: m.read_attribute(:date)
        m.update_column :day_id, day.id
        count += 1
      end
      count
    end

    # 3. remove obsolete columns
    change_table :meals, bulk: true do |t|
      t.remove :canteen_id
      t.remove :date
    end
  end

  def down
    # 1. extends meals table
    change_table :meals do |t|
      t.references :canteen
      t.datetime :date
    end

    # 2. migrate data
    say_with_time "updating meals" do
      Meal.reset_column_information
      Meal.all.each do |m|
        day = Day.find_by(id: m.day_id)
        # way is this needed:
        unless day
          say "WARN: Meal without day: #{m}"
          m.destroy
          next
        end
        m.update_column :date, day.date
        m.update_column :canteen_id, day.canteen_id
      end
    end

    # 3. remove obsolete entity
    remove_column :meals, :day_id
    remove_table :days
  end
end
