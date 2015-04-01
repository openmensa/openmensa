class Source < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :canteen
  belongs_to :parser
  has_many :feeds, -> { order(:priority) }
end
