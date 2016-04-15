class EnterRoomRelationship < ApplicationRecord
  belongs_to :room
  belongs_to :player
  validates :room_id, presence: true
  validates :player_id, presence: true
end
