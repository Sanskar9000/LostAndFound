class PickupVerificationsController < ApplicationController
  before_action :require_staff
  before_action :set_claim

  def show
  end

  def update
    if @claim.pickup_verified?
      redirect_to pickup_verification_path(@claim.pickup_token), alert: "This pickup token has already been used."
      return
    end

    @claim.verify_pickup!(current_user)
    redirect_to pickup_verification_path(@claim.pickup_token), notice: "Pickup verified and item marked as returned."
  end

  private

  def require_staff
    unless current_user.admin? || current_user.faculty?
      redirect_to root_path, alert: "Not authorized."
    end
  end

  def set_claim
    @claim = Claim.includes(:item, :user).find_by!(pickup_token: params[:token])
  end
end
