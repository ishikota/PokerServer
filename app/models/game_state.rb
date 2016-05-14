class GameState < ApplicationRecord
  has_one :game_state_relationship, dependent: :destroy
  has_one :room, through: :game_state_relationship
  validates :state, presence: true
end
