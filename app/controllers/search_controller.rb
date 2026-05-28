class SearchController < ApplicationController
  def index
    @query = params[:q].to_s.strip
    @kpis = build_kpis
    load_results
  end

  private

  def load_results
    if @query.blank?
      @items = Item.includes(:user, :campus).order(created_at: :desc).limit(8)
      @claims = Claim.includes(:item, :user).order(created_at: :desc).limit(8)
      @users = User.includes(:campus).order(created_at: :desc).limit(8)
      return
    end

    pattern = "%#{@query}%"

    @items = Item.includes(:user, :campus)
                 .joins(:user, :campus)
                 .where(
                   "items.title LIKE :q OR items.description LIKE :q OR items.category LIKE :q OR items.location LIKE :q OR items.item_type LIKE :q OR items.status LIKE :q OR users.email LIKE :q OR campuses.name LIKE :q",
                   q: pattern
                 )
                 .distinct
                 .order(created_at: :desc)
                 .limit(20)

    @claims = Claim.includes(:item, :user)
                   .joins(:item, :user)
                   .where(
                     "claims.claim_code LIKE :q OR claims.proof_note LIKE :q OR claims.status LIKE :q OR items.title LIKE :q OR items.category LIKE :q OR users.email LIKE :q",
                     q: pattern
                   )
                   .distinct
                   .order(created_at: :desc)
                   .limit(20)

    @users = User.includes(:campus)
                 .joins(:campus)
                 .where(
                   "users.email LIKE :q OR users.department LIKE :q OR users.role LIKE :q OR campuses.name LIKE :q",
                   q: pattern
                 )
                 .distinct
                 .order(created_at: :desc)
                 .limit(20)
  end

  def build_kpis
    {
      total_items: Item.count,
      open_items: Item.where(status: "open").count,
      returned_items: Item.where(status: "returned").count,
      total_claims: Claim.count,
      pending_claims: Claim.where(status: "pending").count,
      approved_claims: Claim.where(status: "approved").count,
      total_users: User.count,
      faculty_users: User.where(role: "faculty").count
    }
  end
end
