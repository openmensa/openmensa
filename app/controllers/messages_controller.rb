class MessagesController < ApplicationController
  skip_authorization_check

  def overview
    @canteens = @user.canteens.order(:name).map do |canteen|
      message = canteen.messages.order('created_at DESC').limit(1).first
      [ canteen, MessageDecorator.new(message) ]
    end
  end

  def index
    @canteen = @user.canteens.find params[:canteen_id]
    @messages = @canteen.messages
  end
end
