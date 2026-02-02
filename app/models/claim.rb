class Claim < ApplicationRecord
  belongs_to :item
  belongs_to :user

  has_many_attached :proof_files

  scope :pending,  -> { where(status: "pending") }
  scope :approved, -> { where(status: "approved") }
  scope :rejected, -> { where(status: "rejected") }
end