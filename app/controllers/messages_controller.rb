class MessagesController < ApplicationController
  before_action :set_conversation
  before_action :authorize_participant!

  def create
    @message = @conversation.messages.new(message_params)
    @message.sender = current_user

    if @message.save
      respond_to do |format|
        format.turbo_stream { head :ok }
        format.html { redirect_to conversation_path(@conversation) }
      end
    else
      @messages = @conversation.messages.includes(:sender).order(:created_at)
      render "conversations/show", status: :unprocessable_entity
    end
  end

  private

  def set_conversation
    @conversation = ItemConversation.includes(:item, :participant_one, :participant_two).find(params[:conversation_id])
  end

  def authorize_participant!
    redirect_to conversations_path, alert: "Not authorized." unless @conversation.participant?(current_user)
  end

  def message_params
    params.require(:message).permit(:body)
  end
end
