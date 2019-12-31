# frozen_string_literal: true

class Note < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
