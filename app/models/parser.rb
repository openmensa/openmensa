class Parser < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :user
  has_many :sources
  has_many :canteens, through: :sources

  validates :name, presence: true, uniqueness: { scope: :user_id }
end
