# frozen_string_literal: true

class ItemsController < ApplicationController
  before_action :set_item, only: %i[show edit update mark_recovered]
  before_action :authorize_edit!, only: %i[edit update mark_recovered]

  def index
    @campuses = Campus.active.order(:name)
    @current_status = params[:status].in?(%w[open returned]) ? params[:status] : "open"
    @current_item_type = params[:item_type].in?(%w[lost found]) ? params[:item_type] : nil
    @items = Item.includes(:user, :campus).order(created_at: :desc)
    @items = @items.where(status: @current_status)
    @items = @items.where(item_type: @current_item_type) if @current_item_type.present?
    @items = @items.where(campus_id: params[:campus_id]) if params[:campus_id].present?
  end

  def show
  end

  def new
    # type comes from /items/new?type=lost or ?type=found
    @reference_item = Item.includes(:user, :campus).find_by(id: params[:reference_item_id])
    @item = Item.new(prefilled_item_attributes)
  end

  def create
    @reference_item = linked_lost_item
    @item = Item.new(item_params)
    @item.user = current_user
    @item.campus = current_user.campus
    @item.status = "open" if @item.status.blank?

    if save_item_and_close_linked_lost_item
      notify_students_about_new_item!
      notify_lost_item_owner! if should_notify_lost_item_owner?
      redirect_to @item, notice: "Item posted successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @item.update(item_params)
      redirect_to @item, notice: "Item updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def mark_recovered
    unless @item.item_type == "lost" && @item.status == "open"
      return redirect_to @item, alert: "This item cannot be marked as recovered."
    end

    @item.update!(status: "returned")
    redirect_to @item, notice: "This lost item has been marked as recovered."
  end

  private

  def set_item
    @item = Item.includes(:user, :campus, :claims).find(params[:id])
  end

  def authorize_edit!
    return if @item.user_id == current_user.id || current_user.admin?

    redirect_to item_path(@item), alert: "Not authorized."
  end

  def prefilled_item_attributes
    attrs = { item_type: params[:type].presence }
    return attrs unless params[:type] == "found" && @reference_item&.item_type == "lost"

    attrs.merge(
      title: @reference_item.title,
      category: @reference_item.category,
      location: @reference_item.location,
      description: @reference_item.description
    )
  end

  def item_params
    params.require(:item).permit(
      :title,
      :description,
      :item_type,
      :category,
      :location,
      :found_on,
      images: []
    )
  end

  def linked_lost_item
    item = Item.includes(:user, :campus).find_by(id: params[:reference_item_id])
    item if item&.item_type == "lost"
  end

  def save_item_and_close_linked_lost_item
    Item.transaction do
      return false unless @item.save

      close_linked_lost_item! if should_close_linked_lost_item?
    end

    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  def should_close_linked_lost_item?
    @reference_item.present? &&
      @item.item_type == "found" &&
      @reference_item.status == "open"
  end

  def close_linked_lost_item!
    @reference_item.update!(status: "returned")
  end

  def should_notify_lost_item_owner?
    @reference_item.present? &&
      @item.item_type == "found" &&
      @reference_item.user != current_user
  end

  def notify_students_about_new_item!
    student_recipients.find_each do |recipient|
      Notification.notify!(
        recipient: recipient,
        actor: current_user,
        title: student_item_notification_title,
        body: student_item_notification_body,
        kind: student_item_notification_kind,
        link_path: item_path(@item)
      )
    end
  end

  def student_recipients
    User.where(role: "student").where.not(id: current_user.id)
  end

  def student_item_notification_title
    @item.item_type == "lost" ? "New lost item reported" : "New found item reported"
  end

  def student_item_notification_body
    prefix = @item.item_type == "lost" ? "A lost item was just reported" : "A found item was just reported"
    "#{prefix}: #{@item.title}#{@item.campus.present? ? " at #{@item.campus.name}" : ""}."
  end

  def student_item_notification_kind
    @item.item_type == "lost" ? :lost_item_reported : :found_item_reported
  end

  def notify_lost_item_owner!
    Notification.notify!(
      recipient: @reference_item.user,
      actor: current_user,
      title: "Possible match found for your lost item",
      body: "#{current_user.email} posted a found item that may match your lost item: #{@reference_item.title}.",
      kind: :found_match,
      link_path: new_item_claim_path(@item)
    )

    ItemMailer.with(
      lost_item: @reference_item,
      found_item: @item,
      reporter: current_user
    ).found_match_notification.deliver_now
  end
end
