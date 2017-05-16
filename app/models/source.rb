class Source < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :canteen
  belongs_to :parser
  has_many :feeds, -> { order(:priority) }
  has_many :messages, as: :messageable
end
