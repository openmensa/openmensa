class Meal < ActiveRecord::Base
  belongs_to :cafeteria
  has_many :comments, as: :commentee

  attr_accessible :date, :description, :name
end
