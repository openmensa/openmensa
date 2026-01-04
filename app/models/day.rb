# frozen_string_literal: true

class Day < ApplicationRecord
  belongs_to :canteen
  has_many :meals, -> { order(:pos) }, dependent: :destroy, inverse_of: :day

  validates :date, presence: true, uniqueness: {scope: :canteen_id}

  def date=(date)
    self[:date] = begin
      Day.parse(date)
    rescue StandardError
      nil
    end
  end

  def to_param
    date.to_date.iso8601
  end

  class << self
    def parse(value)
      case value
        when NilClass
          value
        when Date
          value.gregorian
        when Time, DateTime
          value.to_date.gregorian
        else
          Date.strptime(value.to_s, "%Y-%m-%d", Date::GREGORIAN)
      end
    end
  end
end
