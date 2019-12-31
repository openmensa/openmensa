# frozen_string_literal: true

class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :canteen

  default_scope -> { order('priority') }
end
