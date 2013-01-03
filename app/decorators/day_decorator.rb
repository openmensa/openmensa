class DayDecorator < Draper::Base
  decorates :day

  def meals
    MealDecorator.decorate(model.meals)
  end
end
