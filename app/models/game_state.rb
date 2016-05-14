class GameState < ApplicationRecord
  has_one :game_state_relationship, dependent: :destroy
  validates :state, presence: true
end
