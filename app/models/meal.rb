class Meal < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :day
  has_one :canteen, through: :day
  has_many :comments, as: :commentee
  has_and_belongs_to_many :notes, autosave: true, readonly: true, uniq: true

  validates :name, :category, :day_id, presence: true

  scope :for, lambda { |date| where('days.date' => date.to_date) }

  def date
    day.date
  end

  def prices
    [:student, :employee, :pupil, :other].inject({}) do |prices, role|
      price = read_attribute :"price_#{role}"
      prices[role] = price if price
      prices
    end
  end
  def prices=(prices)
    prices.each do |role, price|
      write_attribute :"price_#{role}", price
    end
  end

  def notes=(notes)
    super(notes.map do |note|
      note = Note.find_or_create_by_name name: note if note.is_a? String
      note
    end)
  end
end
