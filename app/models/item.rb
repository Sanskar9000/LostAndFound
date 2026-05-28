class Item < ApplicationRecord
  belongs_to :campus
  belongs_to :user
  has_many :claims, dependent: :destroy
  has_many :item_conversations, dependent: :destroy

  has_many_attached :images
end
