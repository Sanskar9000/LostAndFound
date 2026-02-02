class Item < ApplicationRecord
  belongs_to :user
  has_many :claims, dependent: :destroy

  has_many_attached :images
end
