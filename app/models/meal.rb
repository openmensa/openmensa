class Meal < ActiveRecord::Base
  belongs_to :canteen
  has_many :comments, as: :commentee

  attr_accessible :date, :description, :name, :category, :canteen_id, :canteen
  validates :date, :name, :category, :canteen_id, presence: true

  scope :today, lambda { where(date: Time.zone.now.to_date) }

  def date=(date)
    write_attribute :date, date.to_date unless date.nil?
  end
end
