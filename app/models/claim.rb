class Claim < ApplicationRecord
  belongs_to :item
  belongs_to :user
  belongs_to :pickup_verified_by, class_name: "User", optional: true

  has_many_attached :proof_files

  scope :pending,  -> { where(status: "pending") }
  scope :approved, -> { where(status: "approved") }
  scope :rejected, -> { where(status: "rejected") }
  scope :ready_for_pickup, -> { approved.where(pickup_verified_at: nil) }
  scope :picked_up, -> { approved.where.not(pickup_verified_at: nil) }

  validates :pickup_token, uniqueness: true, allow_nil: true

  before_validation :ensure_pickup_payload, if: -> { pickup_token.present? && pickup_qr_payload.blank? }

  def approve_for_pickup!
    ensure_pickup_credentials!
    update!(status: "approved", approved_at: Time.current)
    Notification.notify!(
      recipient: user,
      title: "Claim approved",
      body: "Your claim for #{item&.title || 'an item'} has been approved. Open the claim to view your pickup QR code and token.",
      kind: :claim_approved,
      link_path: "/claims/#{id}"
    )
    ClaimMailer.with(claim: self).approved.deliver_now
  end

  def reject!(reason:, actor: nil)
    update!(status: "rejected", rejection_reason: reason)
    Notification.notify!(
      recipient: user,
      actor: actor,
      title: "Claim rejected",
      body: "Your claim for #{item&.title || 'an item'} was reviewed and could not be approved. Reason: #{reason}",
      kind: :claim_rejected,
      link_path: "/claims/#{id}"
    )
    ClaimMailer.with(claim: self).rejected.deliver_now
  end

  def verify_pickup!(verifier)
    raise ActiveRecord::RecordInvalid, self if pickup_verified_at.present?
    raise ActiveRecord::RecordInvalid, self unless status == "approved"

    transaction do
      update!(
        pickup_verified_at: Time.current,
        pickup_verified_by: verifier
      )
      item.update!(status: "returned") if item.present? && item.status != "returned"
    end

    Notification.notify!(
      recipient: user,
      actor: verifier,
      title: "Pickup verified",
      body: "Your pickup for #{item&.title || 'the item'} has been verified successfully.",
      kind: :pickup_verified,
      link_path: "/claims/#{id}"
    )
  end

  def pickup_verified?
    pickup_verified_at.present?
  end

  def display_pickup_token
    pickup_token.presence || "-"
  end

  def self.find_by_pickup_value(raw_value)
    value = raw_value.to_s.strip
    return nil if value.blank?

    token = value
    if value.include?("token=")
      token = Rack::Utils.parse_nested_query(URI.parse(value).query.to_s)["token"].to_s
    elsif value.match?(%r{/pickup/[^/?#]+})
      token = URI.parse(value).path.to_s.split("/").last.to_s
    elsif value.start_with?("pickup://")
      token = value.split("token=").last.to_s
    end

    find_by(pickup_token: token.presence || value)
  rescue URI::InvalidURIError
    find_by(pickup_token: value)
  end

  private

  def ensure_pickup_credentials!
    return if pickup_token.present? && pickup_qr_payload.present?

    self.pickup_token = generate_unique_pickup_token
    self.pickup_qr_payload = pickup_verification_url_for(pickup_token)
  end

  def ensure_pickup_payload
    self.pickup_qr_payload = pickup_verification_url_for(pickup_token)
  end

  def generate_unique_pickup_token
    loop do
      token = SecureRandom.urlsafe_base64(24)
      break token unless self.class.exists?(pickup_token: token)
    end
  end

  def pickup_verification_url_for(token)
    options = Rails.application.config.action_mailer.default_url_options || {}

    Rails.application.routes.url_helpers.pickup_verification_url(
      token,
      host: options[:host] || "localhost",
      port: options[:port]
    )
  end
end
