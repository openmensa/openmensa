class Meal < ActiveRecord::Base
  belongs_to :day
  has_one :canteen, through: :day
  has_many :comments, as: :commentee

  attr_accessible :description, :name, :category, :day_id, :day
  validates :name, :category, :day_id, presence: true

  def date
    day.date
  end
end
