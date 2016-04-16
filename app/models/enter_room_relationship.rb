class EnterRoomRelationship < ApplicationRecord
  belongs_to :room
  belongs_to :player
  validates :room_id, presence: true
  validates :player_id, presence: true
  validates :player_id, uniqueness: { scope: :room_id,
    message: "player is already in the room"
  }
end
