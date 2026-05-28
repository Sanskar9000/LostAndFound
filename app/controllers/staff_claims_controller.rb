class StaffClaimsController < ApplicationController
  before_action :require_staff
  before_action :set_claim, only: %i[show approve reject verify_pickup]

  def index
    @current_status = params[:status].in?(%w[pending approved picked_up]) ? params[:status] : "pending"
    @claims = filtered_claims
  end

  def show
  end

  def approve
    @claim.approve_for_pickup!
    redirect_to staff_claims_path, notice: "Claim approved."
  end

  def reject
    if params[:rejection_reason].to_s.strip.blank?
      redirect_to staff_claim_path(@claim), alert: "Rejection reason is required."
    else
      @claim.reject!(reason: params[:rejection_reason].to_s.strip, actor: current_user)
      redirect_to staff_claims_path, notice: "Claim rejected."
    end
  end

  def verify_pickup
    claim = Claim.find_by_pickup_value(params[:pickup_value])

    if claim.blank?
      redirect_to staff_claim_path(@claim), alert: "Pickup token not found."
    elsif claim.id != @claim.id
      redirect_to staff_claim_path(@claim), alert: "This pickup token belongs to a different claim."
    elsif claim.pickup_verified?
      redirect_to staff_claim_path(@claim), alert: "This pickup token has already been used."
    else
      claim.verify_pickup!(current_user)
      redirect_to staff_claim_path(claim), notice: "Pickup verified and item marked as returned."
    end
  end

  private

  def require_staff
    unless current_user.admin? || current_user.faculty?
      redirect_to root_path, alert: "Not authorized."
    end
  end

  def set_claim
    @claim = Claim.includes(:item, :user).find(params[:id])
  end

  def filtered_claims
    scope = Claim.includes(:item, :user).order(created_at: :desc)

    case @current_status
    when "approved"
      scope.ready_for_pickup
    when "picked_up"
      scope.picked_up
    else
      scope.pending
    end
  end
end
