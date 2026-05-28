class DashboardController < ApplicationController
  def index
    @current_status = params[:status].in?(%w[open returned]) ? params[:status] : "open"
    @latest_items = Item.includes(:user, :campus)
                        .where(status: @current_status)
                        .order(created_at: :desc)
                        .limit(8)
  end
end
