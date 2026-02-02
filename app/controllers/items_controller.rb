# frozen_string_literal: true

class ItemsController < ApplicationController
  before_action :set_item, only: %i[show edit update]
  before_action :authorize_edit!, only: %i[edit update]

  def index
    @items = Item.includes(:user).order(created_at: :desc)
  end

  def show
  end

  def new
    # type comes from /items/new?type=lost or ?type=found
    @item = Item.new(item_type: params[:type].presence)
  end

  def create
    @item = Item.new(item_params)
    @item.user = current_user
    @item.status = "open" if @item.status.blank?

    if @item.save
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

  private

  def set_item
    @item = Item.includes(:user).find(params[:id])
  end

  def authorize_edit!
    return if @item.user_id == current_user.id || current_user.admin?

    redirect_to item_path(@item), alert: "Not authorized."
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
end