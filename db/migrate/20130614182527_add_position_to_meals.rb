class AddPositionToMeals < ActiveRecord::Migration
  def up
    # 1. add position field
    add_column :meals, :pos, :integer
    Meal.reset_column_information

    # 2. migrate data
    say_with_time 'Generating initial meal sorting' do
      count = 0
      last_day = nil
      pos = nil
      Meal.order('day_id, category, name').select(:id, :day_id).each do |m|
        if m.day_id != last_day
          last_day = m.day_id
          pos = 1
        end
        m.update_attribute :pos, pos
        pos += 1
        count += 1
      end
      count
    end
  end

  def down
    remove_column :meals, :pos
  end
end
