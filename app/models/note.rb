class Note < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
