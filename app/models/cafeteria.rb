class Cafeteria < ActiveRecord::Base
  belongs_to :user
  has_many :meals

  attr_accessible :address, :name, :url, :user
  validates :address, :name, :url, :user_id, presence: true

  def fetch

  end
end
