class Player < ApplicationRecord
  validates :name, presence: true
  validates :credential, length: { is: 22 }

  # most rescent entered room
  def current_room
    my_rooms_id = EnterRoomRelationship.where(player_id: id).pluck(:id)
    Room.where(id: my_rooms_id).order(created_at: :desc).first
  end
end
