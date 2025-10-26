# frozen_string_literal: true

class FavoritesController < WebController
  load_and_authorize_resource :user

  def index
    @favorites = user.favorites.order(:priority).includes(:canteen)
  end

  def create
    max_priority = user.favorites
      .order(:priority)
      .first.try(:priority) || 0

    if user.favorites.create(
      canteen: canteen,
      priority: max_priority,
    )
      flash[:notice] = t("favorites.added")
    else
      flash[:error] = t("favorites.added_error")
    end

    redirect_to canteen_path(canteen)
  end

  def destroy
    f = user.favorites.find_by(canteen: canteen)
    if f.destroy
      flash[:notice] = t("favorites.deleted")
    else
      flash[:error] = t("favorites.deleted_error")
    end
    redirect_to canteen_path(canteen)
  end

  private

  def user
    @user ||= current_user
  end

  def canteen
    @canteen ||= Canteen.find(params[:canteen_id])
  end
end
