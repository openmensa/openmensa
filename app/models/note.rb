class Note < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  attr_accessible :name
  validates :name, presence: true, uniqueness: true
end
