class CreateDayTable < ActiveRecord::Migration
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
    say_with_time 'updating meals' do
      Day.reset_column_information
      Meal.reset_column_information
      Meal.all.each do |m|
        canteen = Canteen.find_by_id m.canteen_id
        # way is this needed:
        if not canteen
          puts 'meals without canteen:', m.inspect
          m.destroy
          next
        end
        day = canteen.days.find_by_date m.read_attribute(:date)
        day ||= canteen.days.create date: m.read_attribute(:date)
        m.update_column :day_id, day.id
      end
    end

    # 3. remove obsolete columns
    remove_column :meals, :canteen_id
    remove_column :meals, :date
  end

  def down
    # 1. extends meals table
    change_table :meals do |t|
      t.references :canteen
      t.datetime :date
    end

    # 2. migrate data
    say_with_time 'updating meals' do
      Meal.reset_column_information
      Meal.all.each do |m|
        day = Day.find_by_id(m.day_id)
        # way is this needed:
        if not day
          puts 'meals without day:', m.inspect
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
