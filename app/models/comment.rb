class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :commentee
  attr_accessible :message
end
