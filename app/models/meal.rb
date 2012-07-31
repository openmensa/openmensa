class Meal < ActiveRecord::Base
  belongs_to :canteen
  has_many :comments, as: :commentee

  attr_accessible :date, :description, :name, :category, :canteen_id, :canteen
  validates :date, :name, :category, :canteen_id, presence: true

  scope :on, lambda { |date| where(date: date.to_date) }
  scope :today, lambda { where(date: Time.now.to_date) }
  scope :tomorrow, lambda { where(date: Time.now.to_date + 1.day) }

  def date=(date)
    write_attribute :date, date.to_date unless date.nil?
  end
end
