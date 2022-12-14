# frozen_string_literal: true

class FavoritesController < WebController
  load_and_authorize_resource

  def index
    @favorites = @user.favorites.order("priority").includes(:canteen)
  end
  def create
    max_priority = current_user
      .favorites
      .order("priority ASC")
      .first.try(:priority) || 0

    if current_user.favorites.create(
      canteen_id: params[:canteen_id],
      priority: max_priority
    )
      flash[:notice] = t("favorites.added")
    else
      flash[:error] = t("favorites.added_error")
    end

    redirect_to canteen_path(params[:canteen_id])
  end

  def destroy
    f = current_user.favorites.find_by canteen_id: params[:canteen_id]
    if f.destroy
      flash[:notice] = t("favorites.deleted")
    else
      flash[:error] = t("favorites.deleted_error")
    end
    redirect_to canteen_path(params[:canteen_id])
  end

end
