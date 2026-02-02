class StaffClaimsController < ApplicationController
  before_action :require_staff

  def index
    @claims = Claim.includes(:item, :user)
                  .where(status: "pending")
                  .order(created_at: :desc)
  end

  def show
    @claim = Claim.includes(:item, :user).find(params[:id])
  end

  def approve
    claim = Claim.find(params[:id])
    claim.update!(
      status: "approved",
      approved_at: Time.current,
    )

    claim.item.update!(status: "returned") if claim.item.present?

    redirect_to staff_claims_path, notice: "Claim approved."
  end

  def reject
    claim = Claim.find(params[:id])
    claim.update!(status: "rejected", approved_by: current_user)
    redirect_to staff_claims_path, notice: "Claim rejected."
  end

  private

  def require_staff
    unless current_user.admin? || current_user.faculty?
      redirect_to root_path, alert: "Not authorized."
    end
  end
end