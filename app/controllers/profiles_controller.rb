class ProfilesController < ApplicationController
  before_action :set_collections, only: %i[edit update]

  def show
    @user = current_user
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    @user.profile_image.purge if params[:remove_profile_image] == "1" && @user.profile_image.attached?

    if @user.update(profile_params)
      redirect_to profile_path, notice: "Profile updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:campus_id, :department, :profile_image)
  end

  def set_collections
    @campuses = Campus.active.order(:name)
    @departments = ["Computer Science", "IT", "Mechanical", "Civil", "Electrical", "Electronics", "Other"]
  end
end
