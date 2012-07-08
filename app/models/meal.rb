class Meal < ActiveRecord::Base
  belongs_to :cafeteria
  has_many :comments, as: :commentee

  attr_accessible :date, :description, :name, :category, :cafeteria_id, :cafeteria
  validates :date, :name, :category, :cafeteria_id, presence: true

  def date=(date)
    write_attribute :date, date.to_date unless date.nil?
  end
end
