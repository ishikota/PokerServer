class Room < ApplicationRecord
  has_many :enter_room_relationships
  has_many :players, through: :enter_room_relationships
  validates :name, presence: true
  validates :max_round, numericality: { greater_than: 0 }
  validates :player_num, numericality: { greater_than: 0 }
end
