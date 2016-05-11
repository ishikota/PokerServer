class GameStateRelationship < ApplicationRecord
  validates :room_id, presence: true
  validates :game_state_id, presence: true
end
