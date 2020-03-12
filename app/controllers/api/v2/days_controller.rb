# frozen_string_literal: true

class Api::V2::DaysController < Api::BaseController
  respond_to :json

  has_scope :start, default: 'true' do |_controller, scope, value|
    begin
      value = Date.strptime(value, '%Y-%m-%d')
    rescue ArgumentError
      value = Time.zone.today
    end
    scope.where('days.date >= ?', value)
  end

  def default_scope(scope)
    @canteen = Canteen.find params[:canteen_id]
    scope.where(canteen_id: @canteen.id)
  end

  def find_resource
    scoped_resource.find_by! date: params[:id]
  end
end
