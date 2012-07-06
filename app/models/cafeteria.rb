class Cafeteria < ActiveRecord::Base
  belongs_to :user
  has_many :meals

  attr_accessible :address, :name, :url
  validates :address, :name, :url, :user_id, presence: true
end
