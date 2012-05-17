class Identity < ActiveRecord::Base
  belongs_to :user
  attr_accessible :provider, :secret, :token, :uid
end
