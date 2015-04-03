class Parser < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :user
  has_many :sources

  validates :name, presence: true, uniqueness: { scope: :user_id }
end
