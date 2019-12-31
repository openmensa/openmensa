# frozen_string_literal: true

class DataProposal < ApplicationRecord
  belongs_to :user
  belongs_to :canteen
end
