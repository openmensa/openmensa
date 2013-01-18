class MealDecorator < Draper::Decorator
  include ApiDecorator
  decorates :meal

  def notes
    model.notes.map(&:name)
  end

  def prices
    {
      students: model.price_student.try(:to_f),
      employees: model.price_employee.try(:to_f),
      pupils: model.price_pupil.try(:to_f),
      others: model.price_other.try(:to_f)
    }
  end

  def to_version_1(options)
    {
      meal: {
        id: model.id,
        name: model.name,
        description: model.description,
        date: model.date.to_date.iso8601
      }
    }
  end

  def to_version_2(options)
    {
      id: model.id,
      name: model.name,
      category: model.category,
      prices: prices,
      notes: notes
    }
  end
end
