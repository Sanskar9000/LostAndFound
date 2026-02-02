class ClaimsController < ApplicationController
  def index
    if current_user.admin? || current_user.faculty?
      @claims = Claim.includes(:item, :user).order(created_at: :desc)
    else
      @claims = Claim.includes(:item).where(user_id: current_user.id).order(created_at: :desc)
    end
  end

  def show
    @claim = Claim.includes(:item).find(params[:id])
    redirect_to claims_path, alert: "Not authorized." unless @claim.user_id == current_user.id || current_user.admin?
  end

  def new
    @item = Item.find(params[:item_id])
    @claim = Claim.new
  end

  def create
    @item = Item.find(params[:item_id])
    @claim = Claim.new(claim_params)
    @claim.item = @item
    @claim.user = current_user
    @claim.status = "pending"
    @claim.claim_code = "CLM-#{SecureRandom.hex(3).upcase}"

    if @claim.save
      redirect_to claims_path, notice: "Claim submitted successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def claim_params
    params.require(:claim).permit(:proof_note, proof_files: [])
  end
end