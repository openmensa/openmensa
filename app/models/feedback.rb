class Feedback < ActiveRecord::Base
  belongs_to :user
  belongs_to :canteen
  validates :message, presence: true
end
