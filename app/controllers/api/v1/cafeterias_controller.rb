class Api::V1::CafeteriasController < Api::V1::BaseController

  def index
    @cafeterias = Cafeteria.all
  end

  def show
    @cafeteria = Cafeteria.find params[:id]
  end
end
