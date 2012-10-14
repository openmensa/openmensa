class Day < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :canteen
  has_many :meals

  attr_accessible :date
  validates :date, :canteen_id, presence: true
  validates :date, uniqueness: { scope: :canteen_id }

  def date=(date)
    write_attribute :date, date.to_date unless date.nil?
  end
end
