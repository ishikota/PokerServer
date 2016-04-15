class Room < ApplicationRecord
  validates :name, presence: true
  validates :max_round, numericality: { greater_than: 0 }
  validates :player_num, numericality: { greater_than: 0 }
end
