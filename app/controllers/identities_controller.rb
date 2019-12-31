# frozen_string_literal: true

class IdentitiesController < ApplicationController
  load_and_authorize_resource

  def new
    @identities = current_user.identities.map(&:provider)
  end

  def destroy
    @identity = current_user.identities.find(params[:id])
    if @identity.destroy
      redirect_to user_path(current_user), notice: t("message.identity_removed.#{@identity.provider}").html_safe
    else
      redirect_to root_path
    end
  end
end
