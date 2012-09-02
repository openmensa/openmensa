class Day < ActiveRecord::Base
  belongs_to :canteen
  has_many :meals

  attr_accessible :date
  validates :date, :canteen_id, presence: true

  def date=(date)
    write_attribute :date, date.to_date unless date.nil?
  end
end
