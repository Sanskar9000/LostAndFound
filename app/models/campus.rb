class Campus < ApplicationRecord
  has_many :users, dependent: :restrict_with_exception
  has_many :items, dependent: :restrict_with_exception

  scope :active, -> { where(active: true) }

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
end
