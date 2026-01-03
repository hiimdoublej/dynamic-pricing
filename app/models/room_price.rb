class RoomPrice < ApplicationRecord
  validates :period, presence: true
  validates :hotel, presence: true
  validates :room, presence: true
  validates :price, presence: true

  validates :period, uniqueness: { scope: [:hotel, :room] }
end
