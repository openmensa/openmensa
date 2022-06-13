# frozen_string_literal: true

class Day < ApplicationRecord
  belongs_to :canteen
  has_many :meals, -> { order(:pos) }, dependent: :destroy, inverse_of: :day

  validates :date, presence: true, uniqueness: {scope: :canteen_id}

  def date=(date)
    self[:date] = date.to_date unless date.nil?
  end

  def to_param
    date.to_date.iso8601
  end
end
