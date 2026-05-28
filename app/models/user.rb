class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  before_validation :set_defaults, on: :create
  before_validation :sanitize_signup_role, on: :create
  before_create :skip_confirmation_for_non_students

  belongs_to :campus
  has_many :items, dependent: :destroy
  has_many :claims, dependent: :destroy
  has_many :initiated_item_conversations, class_name: "ItemConversation", foreign_key: :participant_one_id, dependent: :destroy
  has_many :received_item_conversations, class_name: "ItemConversation", foreign_key: :participant_two_id, dependent: :destroy
  has_many :notifications, foreign_key: :recipient_id, dependent: :destroy
  has_many :sent_notifications, class_name: "Notification", foreign_key: :actor_id, dependent: :nullify
  has_one_attached :profile_image

  validates :department, presence: true
  validates :campus, presence: true
  validates :role, inclusion: { in: %w[student faculty admin] }

  def admin?
    role == "admin"
  end

  def faculty?
    role == "faculty"
  end

  def student?
    role == "student"
  end

  def item_conversations
    ItemConversation.where("participant_one_id = :id OR participant_two_id = :id", id: id)
  end

  # ✅ Devise hook: prevent login if faculty not verified
  def active_for_authentication?
    super && (admin? || student? || (faculty? && verified?))
  end

  # Message shown by Devise when blocked
  def inactive_message
    (faculty? && !verified?) ? :account_under_verification : super
  end

  def after_confirmation
    Notification.notify!(
      recipient: self,
      title: "Welcome to Campus Lost & Found",
      body: "Your email has been verified successfully. You can now sign in and start using the app.",
      kind: :welcome,
      link_path: "/users/sign_in"
    ) if student?
    UserMailer.with(user: self).student_welcome.deliver_now if student?
  end

  private

  def set_defaults
    self.role = "student" if role.blank?
    self.verified = true if verified.nil?

    # if signing up as faculty, must be unverified initially
    self.verified = false if role == "faculty"
  end

  def sanitize_signup_role
    # prevent any signup from becoming admin
    self.role = "student" unless role.in?(%w[student faculty])
  end

  def skip_confirmation_for_non_students
    skip_confirmation! unless student?
  end
end
