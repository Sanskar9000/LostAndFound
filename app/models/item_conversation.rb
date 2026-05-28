class ItemConversation < ApplicationRecord
  belongs_to :item
  belongs_to :participant_one, class_name: "User"
  belongs_to :participant_two, class_name: "User"

  has_many :messages, dependent: :destroy

  validates :participant_one_id, uniqueness: { scope: [:item_id, :participant_two_id] }
  validate :participants_must_be_different

  scope :recent, -> { order(updated_at: :desc) }

  def self.between(item:, user_a:, user_b:)
    one, two = [user_a.id, user_b.id].sort
    find_by(item: item, participant_one_id: one, participant_two_id: two)
  end

  def self.find_or_create_between!(item:, user_a:, user_b:)
    one, two = [user_a.id, user_b.id].sort
    find_or_create_by!(item: item, participant_one_id: one, participant_two_id: two)
  end

  def participant?(user)
    [participant_one_id, participant_two_id].include?(user.id)
  end

  def other_participant(user)
    participant_one_id == user.id ? participant_two : participant_one
  end

  def unread_messages_for(user)
    messages.where.not(sender_id: user.id).where(read_at: nil)
  end

  private

  def participants_must_be_different
    errors.add(:participant_two_id, "must be different") if participant_one_id == participant_two_id
  end
end
