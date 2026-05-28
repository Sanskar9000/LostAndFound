class ConversationsController < ApplicationController
  before_action :set_conversation, only: :show
  before_action :authorize_participant!, only: :show

  def index
    @conversations = current_user.item_conversations.includes(:item, :participant_one, :participant_two, :messages).recent
    @conversations = @conversations.where(item_id: params[:item_id]) if params[:item_id].present?
  end

  def show
    @messages = @conversation.messages.includes(:sender).order(:created_at)
    @message = @conversation.messages.new
    mark_incoming_messages_as_read!
  end

  private

  def set_conversation
    @conversation = ItemConversation.includes(:item, :participant_one, :participant_two).find(params[:id])
  end

  def authorize_participant!
    redirect_to conversations_path, alert: "Not authorized." unless @conversation.participant?(current_user)
  end

  def mark_incoming_messages_as_read!
    @conversation.unread_messages_for(current_user).find_each(&:mark_as_read!)
    current_user.notifications.where(kind: :message_received, link_path: conversation_path(@conversation), read_at: nil).update_all(read_at: Time.current)
  end
end
