class MessagesChannel < ApplicationCable::Channel
  def subscribed
    conversation = ItemConversation.find_by(id: params[:conversation_id])
    reject unless conversation&.participant?(current_user)

    stream_for conversation
  end
end
