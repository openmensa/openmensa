class Feed < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :source
  has_many :fetches, class_name: 'FeedFetch'
  has_many :messages, as: :messageable

  def canteen
    source.canteen
  end
end
