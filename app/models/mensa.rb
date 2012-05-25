class Mensa < ActiveRecord::Base
  belongs_to :user
  attr_accessible :address, :name, :url
end
