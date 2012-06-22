class Cafeteria < ActiveRecord::Base
  belongs_to :user
  has_many :meals

  attr_accessible :address, :name, :url
end
