class Notification < ApplicationRecord
  belongs_to :recipient, class_name: "User"
  belongs_to :actor, class_name: "User", optional: true

  enum :kind, {
    general: "general",
    found_match: "found_match",
    lost_item_reported: "lost_item_reported",
    found_item_reported: "found_item_reported",
    claim_submitted: "claim_submitted",
    message_received: "message_received",
    claim_approved: "claim_approved",
    claim_rejected: "claim_rejected",
    welcome: "welcome",
    faculty_verified: "faculty_verified",
    pickup_verified: "pickup_verified"
  }, default: :general

  scope :recent, -> { order(created_at: :desc) }
  scope :unread, -> { where(read_at: nil) }

  validates :title, presence: true
  validates :body, presence: true

  after_create_commit :broadcast_created

  def self.notify!(recipient:, title:, body:, kind: :general, link_path: nil, actor: nil)
    create!(
      recipient: recipient,
      actor: actor,
      kind: kind,
      title: title,
      body: body,
      link_path: link_path
    )
  end

  def mark_as_read!
    update!(read_at: Time.current) if read_at.blank?
  end

  def unread?
    read_at.blank?
  end

  def created_at_label
    created_at.strftime("%d %b %Y, %I:%M %p")
  end

  private

  def broadcast_created
    NotificationsChannel.broadcast_to(
      recipient,
      {
        id: id,
        title: title,
        body: body,
        link_path: link_path,
        unread_count: recipient.notifications.unread.count,
        item_html: ApplicationController.render(
          partial: "notifications/notification",
          locals: { notification: self }
        )
      }
    )
  end
end
