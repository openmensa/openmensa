class Feed < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :source
end
