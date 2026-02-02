class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  before_validation :set_defaults, on: :create
  before_validation :sanitize_signup_role, on: :create

  has_many :items, dependent: :destroy
  has_many :claims, dependent: :destroy

  validates :department, presence: true
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

  # ✅ Devise hook: prevent login if faculty not verified
  def active_for_authentication?
    super && (admin? || student? || (faculty? && verified?))
  end

  # Message shown by Devise when blocked
  def inactive_message
    (faculty? && !verified?) ? :account_under_verification : super
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
end