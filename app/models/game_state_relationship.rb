class GameStateRelationship < ApplicationRecord
  belongs_to :room
  belongs_to :game_state
  validates :room_id, presence: true
  validates :game_state_id, presence: true
end
