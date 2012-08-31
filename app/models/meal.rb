class Meal < ActiveRecord::Base
  belongs_to :day
  has_one :canteen, through: :day
  has_many :comments, as: :commentee

  attr_accessible :description, :name, :category, :day_id, :day, :prices, :price_student, :price_employee, :price_pupil, :price_other
  validates :name, :category, :day_id, presence: true

  def date
    day.date
  end

  def prices
    [:student, :employee, :pupil, :other].inject({}) do |prices, role|
      price = read_attribute :"price_#{role}"
      prices[role] = price if price
      prices
    end
  end
  def prices=(prices)
    prices.each do |role, price|
      write_attribute :"price_#{role}", price
    end
  end
end
