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
        canteen = Canteen.find_by_id(m.canteen_id)
        # way is this needed:
        if not canteen
          puts 'meals without canteen:', m.inspect
          m.destroy
          next
        end
        day = canteen.days.find_by_date(m.date)
        day ||= canteen.days.create(date: m.date)
        m.update_column :day_id, day.id
      end
    end

    # 3. remove obsolete columns
    remove_column :meals, :canteen_id
    remove_column :meals, :date
  end

  def down
  end
end
