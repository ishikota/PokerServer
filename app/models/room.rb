class Room < ApplicationRecord
  has_one :game_state_relationship, dependent: :destroy
  has_one :game_state, through: :game_state_relationship
  has_many :enter_room_relationships, dependent: :destroy
  has_many :players, through: :enter_room_relationships
  validates :name, presence: true
  validates :max_round, numericality: { greater_than: 0 }
  validates :player_num, numericality: { greater_than: 0 }

  def filled_to_capacity?
    player_num == players.size
  end

  def clear_state
    state_ids = GameStateRelationship.joins(:game_state)
        .where(room_id: id).pluck(:game_state_id)
    GameState.where(id: state_ids).destroy_all
  end

end
