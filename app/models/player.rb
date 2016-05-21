class Player < ApplicationRecord
  has_one :enter_room_relationship
  has_one :room, through: :enter_room_relationship
  validates :name, presence: true
  validates :credential, length: { is: 22 }
  validates :online, inclusion: { in: [true, false] }

  def clear_state
    update_attributes(uuid: nil)
    update_attributes(online: false)
    EnterRoomRelationship.where(player_id: id).destroy_all
  end

  # most rescent entered room
  def current_room
    room
  end

  def take_a_seat(room)
    EnterRoomRelationship.where(player_id: id, room_id: room.id).first_or_create.touch
  end

end
