class Rating < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :meal
  belongs_to :user
  attr_accessible :date, :value
end
