# frozen_string_literal: true

class AddPricesToMeals < ActiveRecord::Migration[4.2]
  def change
    change_table :meals, bulk: true do |t|
      t.decimal :price_student, precision: 8, scale: 2
      t.decimal :price_employee, precision: 8, scale: 2
      t.decimal :price_pupil, precision: 8, scale: 2
      t.decimal :price_other, precision: 8, scale: 2
    end
  end
end
