class Player < ApplicationRecord
  validates :name, presence: true
  validates :credential, length: { is: 22 }

  def clear_state
    update_attributes(uuid: nil)
    EnterRoomRelationship.where(player_id: id).destroy_all
  end

  # most rescent entered room
  def current_room
    my_rooms_id = EnterRoomRelationship.where(player_id: id).pluck(:id)
    Room.where(id: my_rooms_id).order(created_at: :desc).first
  end

  def take_a_seat(room)
    EnterRoomRelationship.where(player_id: id, room_id: room.id).first_or_create.touch
  end

end
