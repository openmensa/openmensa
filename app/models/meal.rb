class Meal < ActiveRecord::Base
  belongs_to :mensa
  attr_accessible :date, :description, :name
end
