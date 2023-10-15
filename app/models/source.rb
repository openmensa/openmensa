# frozen_string_literal: true

class Source < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :canteen
  belongs_to :parser
  has_many :feeds, -> { order(:priority) }, dependent: :destroy
  has_many :messages, as: :messageable, dependent: :destroy

  validates :name, presence: true
end
