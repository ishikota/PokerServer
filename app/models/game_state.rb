class GameState < ApplicationRecord
  has_one :game_state_relationship, dependent: :destroy
  has_one :room, through: :game_state_relationship
  validates :state, presence: true
  validates :ask_counter, numericality: { greater_than_or_equal_to: 0 }
end
