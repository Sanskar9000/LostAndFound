class ClaimsController < ApplicationController
  def index
    @current_status = params[:status].in?(%w[pending approved rejected]) ? params[:status] : "pending"

    if current_user.admin? || current_user.faculty?
      @claims = Claim.includes(:item, :user).order(created_at: :desc)
    else
      @claims = Claim.includes(:item).where(user_id: current_user.id).order(created_at: :desc)
    end

    @claims = @claims.where(status: @current_status)
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
      notify_campus_faculty_about_new_claim!
      redirect_to claims_path, notice: "Claim submitted successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def claim_params
    params.require(:claim).permit(:proof_note, proof_files: [])
  end

  def notify_campus_faculty_about_new_claim!
    campus_faculty_recipients.find_each do |faculty|
      Notification.notify!(
        recipient: faculty,
        actor: current_user,
        title: "New claim submitted",
        body: "#{current_user.email} submitted a new claim for #{@item.title} on #{@item.campus&.name || 'this campus'}.",
        kind: :claim_submitted,
        link_path: staff_claim_path(@claim)
      )
    end
  end

  def campus_faculty_recipients
    User.where(role: "faculty", campus_id: @item.campus_id).where.not(id: current_user.id)
  end
end
