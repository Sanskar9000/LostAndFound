require "csv"

class AnalyticsController < ApplicationController
  before_action :require_staff

  def index
    @range = params[:range].in?(%w[today week month year]) ? params[:range] : "week"
    @range_label = @range.capitalize
    @date_range = selected_date_range
    @items_scope = scoped_items
    @claims_scope = scoped_claims
    @students_scope = scoped_students
    @kpis = build_kpis

    respond_to do |format|
      format.html
      format.csv do
        send_data export_csv,
                  filename: analytics_filename,
                  type: "text/csv"
      end
    end
  end

  private

  def require_staff
    redirect_to root_path, alert: "Not authorized." unless current_user.admin? || current_user.faculty?
  end

  def selected_date_range
    now = Time.current

    case @range
    when "today"
      now.beginning_of_day..now.end_of_day
    when "month"
      now.beginning_of_month..now.end_of_month
    when "year"
      now.beginning_of_year..now.end_of_year
    else
      now.beginning_of_week..now.end_of_week
    end
  end

  def campus_scope_required?
    current_user.faculty? && !current_user.admin?
  end

  def scoped_items
    scope = Item.includes(:user, :campus).where(created_at: @date_range).order(created_at: :desc)
    scope = scope.where(campus_id: current_user.campus_id) if campus_scope_required?
    scope
  end

  def scoped_claims
    scope = Claim.includes(:item, :user).where(created_at: @date_range).order(created_at: :desc)
    scope = scope.joins(:item).where(items: { campus_id: current_user.campus_id }) if campus_scope_required?
    scope
  end

  def scoped_students
    scope = User.includes(:campus).where(role: "student", created_at: @date_range).order(created_at: :desc)
    scope = scope.where(campus_id: current_user.campus_id) if campus_scope_required?
    scope
  end

  def build_kpis
    {
      total_items: @items_scope.count,
      lost_items: @items_scope.where(item_type: "lost").count,
      found_items: @items_scope.where(item_type: "found").count,
      returned_items: @items_scope.where(status: "returned").count,
      total_claims: @claims_scope.count,
      pending_claims: @claims_scope.where(status: "pending").count,
      approved_claims: @claims_scope.where(status: "approved").count,
      rejected_claims: @claims_scope.where(status: "rejected").count,
      total_students: @students_scope.count
    }
  end

  def export_csv
    case params[:dataset]
    when "claims"
      claims_csv
    when "students"
      students_csv
    else
      items_csv
    end
  end

  def analytics_filename
    dataset = params[:dataset].presence_in(%w[items claims students]) || "items"
    "analytics_#{dataset}_#{@range}_#{Date.current}.csv"
  end

  def items_csv
    CSV.generate(headers: true) do |csv|
      csv << ["ID", "Title", "Type", "Status", "Category", "Location", "Campus", "Reported By", "Reported At"]
      @items_scope.find_each do |item|
        csv << [
          item.id,
          item.title,
          item.item_type,
          item.status,
          item.category,
          item.location,
          item.campus&.name,
          item.user&.email,
          item.created_at
        ]
      end
    end
  end

  def claims_csv
    CSV.generate(headers: true) do |csv|
      csv << ["ID", "Claim Code", "Item", "Status", "Claimed By", "Campus", "Submitted At", "Approved At", "Rejection Reason"]
      @claims_scope.find_each do |claim|
        csv << [
          claim.id,
          claim.claim_code,
          claim.item&.title,
          claim.status,
          claim.user&.email,
          claim.item&.campus&.name,
          claim.created_at,
          claim.approved_at,
          claim.rejection_reason
        ]
      end
    end
  end

  def students_csv
    CSV.generate(headers: true) do |csv|
      csv << ["ID", "Email", "Campus", "Department", "Verified", "Joined At"]
      @students_scope.find_each do |student|
        csv << [
          student.id,
          student.email,
          student.campus&.name,
          student.department,
          student.verified,
          student.created_at
        ]
      end
    end
  end
end
