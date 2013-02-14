class Note < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  validates :name, presence: true, uniqueness: true
end
