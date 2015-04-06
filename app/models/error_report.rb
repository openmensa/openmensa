class ErrorReport < ActiveRecord::Base
  belongs_to :user
  belongs_to :canteen
  validate :message, presence: true
end
