class Rating < ActiveRecord::Base
  belongs_to :meal
  belongs_to :user
  attr_accessible :date, :value
end
