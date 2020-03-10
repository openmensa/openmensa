# frozen_string_literal: true

class Meal < ApplicationRecord
  belongs_to :day
  has_one :canteen, through: :day
  has_and_belongs_to_many :notes, autosave: true

  validates :name, :category, :day_id, presence: true

  scope :for, ->(date) { where('days.date' => date.to_date) }

  delegate :date, to: :day

  def prices
    %i[student employee pupil other].each_with_object({}) do |role, prices|
      price = self[:"price_#{role}"]
      prices[role] = price if price
    end
  end

  def prices=(prices)
    prices.each do |role, price|
      self[:"price_#{role}"] = price
    end
  end

  def notes=(notes)
    super(notes.map do |note|
      note = Note.find_or_create_by(name: note) if note.is_a? String
      note
    end)
  end
end
