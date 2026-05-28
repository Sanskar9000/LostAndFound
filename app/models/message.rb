class Message < ApplicationRecord
  belongs_to :item_conversation, touch: true
  belongs_to :sender, class_name: "User"

  validates :body, presence: true

  after_create_commit :broadcast_created
  after_create_commit :notify_recipient

  def recipient
    item_conversation.other_participant(sender)
  end

  def created_at_label
    created_at.strftime("%d %b %Y, %I:%M %p")
  end

  def mark_as_read!
    update!(read_at: Time.current) if read_at.blank?
  end

  private

  def broadcast_created
    MessagesChannel.broadcast_to(
      item_conversation,
      {
        conversation_id: item_conversation.id,
        message: {
          id: id,
          sender_id: sender_id,
          sender_email: sender.email,
          body: body,
          created_at_label: created_at_label
        }
      }
    )
  end

  def notify_recipient
    Notification.notify!(
      recipient: recipient,
      actor: sender,
      title: "New message about #{item_conversation.item.title}",
      body: body.truncate(120),
      kind: :message_received,
      link_path: Rails.application.routes.url_helpers.conversation_path(item_conversation)
    )
  end
end
