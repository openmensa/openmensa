class Rating < ApplicationRecord
  belongs_to :meal
  belongs_to :user
end
