class Parser < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :user
  has_many :sources
  has_many :canteens, through: :sources
  has_many :messages, as: :messageable

  validates :name, presence: true, uniqueness: { scope: :user_id }

  def info_box?
    [
      maintainer_wanted?,
      info_url.present?,
      user.public_email.present?,
      user.public_name.present?,
      user.info_url.present?
    ].any?
  end
end
