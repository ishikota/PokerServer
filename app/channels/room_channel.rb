# Be sure to restart your server when you modify this file. Action Cable runs in an EventMachine loop that does not support auto reloading.
class RoomChannel < ApplicationCable::Channel
  unloadable
  include RoomChannelHelper

  def subscribed
    # stream_from "some_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def enter_room(data)
    room = Room.find(data['room_id'])
    player = Player.find(data['player_id'])
    player.take_a_seat(room)

    stream_from "room:#{room.id}"
    stream_from "room:#{room.id}:#{player.id}"
    ActionCable.server.broadcast "room:#{room.id}", enter_room_message(room, player)
    ActionCable.server.broadcast "room:#{room.id}:#{player.id}", welcome_message

    if room.reload.filled_to_capacity?
      ActionCable.server.broadcast "room:#{room.id}", ready_message
    end
  end

  def exit_room(data)
    room = Room.find(data['room_id'])
    player = Player.find(data['player_id'])
    player.leave_a_seat(room)
    room.reload

    ActionCable.server.broadcast "room:#{room.id}", exit_room_message(room, player)
  end

  def declare_action(data)
    room = Room.find(data['room_id'])
    player = Player.find(data['player_id'])
    # TODO fetch dealer from hash and resume_round with passed data
    ActionCable.server.broadcast "room:#{room.id}:#{player.id}", action_accept_message
  end


  private

    def welcome_message
      {}.merge!(phase: "member_wanted")\
        .merge!(type: "welcome")
    end

    def enter_room_message(room, player)
      {}.merge!(phase: "member_wanted")\
        .merge!(type: "arrival")\
        .merge!(message: generate_arrival_message(room, player))
    end

    def exit_room_message(room, player)
      {}.merge!(phase: "member_wanted")\
        .merge!(type: "leave")\
        .merge!(message: generate_leave_message(room, player))
    end

    def ready_message
      {}.merge!(phase: "member_wanted")\
        .merge!(type: "ready")\
        .merge!(message: generate_game_info(room))
    end

    def action_accept_message
      {}.merge!(phase: "player_poker")\
        .merge!(type: "accept")\
        .merge!(type: "action accepted")
    end

end
