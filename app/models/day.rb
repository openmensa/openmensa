# frozen_string_literal: true

class Day < ApplicationRecord
  # The limit into the future we accept or show data for. Let's assume
  # that everything after is is either a parser error or some crawler.
  MAX_FUTURE = 180.days

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
    def upcoming_dates
      today = Time.zone.today
      today..(today + MAX_FUTURE)
    end

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
