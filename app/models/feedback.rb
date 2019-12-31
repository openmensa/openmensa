# frozen_string_literal: true

class Feedback < ApplicationRecord
  belongs_to :user
  belongs_to :canteen
  validates :message, presence: true
end
