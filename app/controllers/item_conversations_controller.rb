class ItemConversationsController < ApplicationController
  def create
    item = Item.includes(:user).find(params[:item_id])

    if item.user == current_user
      redirect_to item_path(item), alert: "You cannot start a chat with yourself."
      return
    end

    conversation = ItemConversation.find_or_create_between!(item: item, user_a: current_user, user_b: item.user)
    redirect_to conversation_path(conversation)
  end
end
