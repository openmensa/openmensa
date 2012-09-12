class MealDecorator < Draper::Base
  include ApiDecorator
  decorates :meal
  api_attributes :id, :name, :category, :prices, :notes

  def notes
    meal.notes.map(&:name)
  end

  def prices
    {
      students: meal.price_student,
      employees: meal.price_employee,
      pupils: meal.price_pupil,
      others: meal.price_other
    }
  end
end
