class Comment < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :user
  belongs_to :commentee

  attr_accessible :message, :user
end
