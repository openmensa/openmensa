class Day < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :canteen
  has_many :meals, -> { order(:pos) }

  validates :date, :canteen_id, presence: true
  validates :date, uniqueness: { scope: :canteen_id }

  def date=(date)
    write_attribute :date, date.to_date unless date.nil?
  end

  def to_param
    date.to_date.iso8601
  end
end
