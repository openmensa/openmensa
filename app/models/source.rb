# frozen_string_literal: true

class Source < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :canteen, optional: true
  belongs_to :parser
  has_many :feeds, -> { order(:priority) }, inverse_of: :source, dependent: :destroy
  has_many :messages, as: :messageable, dependent: :destroy

  validates :name, presence: true
end
