# Be sure to restart your server when you modify this file. Action Cable runs in an EventMachine loop that does not support auto reloading.
class RoomChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def enter_room(data)
    stream_from "room:#{data['room_id']}"
    stream_from "room:#{data['room_id']}:#{data['player_id']}"
    ActionCable.server.broadcast "room:#{data['room_id']}", enter_room_message
    ActionCable.server.broadcast "room:#{data['room_id']}:#{data['player_id']}", welcome_message
    # check if member is gathered
    # if so send ready message
  end

  def speak_in_room(data)
    ActionCable.server.broadcast "room:#{data['room_id']}", message: data['message']
  end

  def declare_action(data)
    ActionCable.server.broadcast 'room_channel', message: data['message']
  end

  private

    def welcome_message
      {}.merge!(phase: "member_wanted")\
        .merge!(type: "welcome")
    end

    def enter_room_message
      {}.merge!(phase: "member_wanted")\
        .merge!(type: "arrival")\
        .merge!(message: "TODO")
    end
end
