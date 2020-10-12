# frozen_string_literal: true

class AddNotesToMeal < ActiveRecord::Migration[4.2]
  def change
    create_table :notes do |t|
      t.string :name, null: false
      t.timestamps
    end
    add_index :notes, :name, unique: true

    create_table :meals_notes do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.references :meal
      t.references :note
    end

    say_with_time "extracting notes from description field" do
      count = 0
      Meal.all.each do |meal|
        meal.notes = (meal.description || "").split('\n').map do |text|
          Note.find_or_create_by_name name: text
        end
        meal.description = nil
        meal.save! if meal.changed?
        count += 1
      end
      count
    end
  end
end
