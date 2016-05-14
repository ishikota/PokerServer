class GameState < ApplicationRecord
  validates :state, presence: true
end
