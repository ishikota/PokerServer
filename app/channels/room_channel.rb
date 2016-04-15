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
  end

  def speak_in_room(data)
    ActionCable.server.broadcast "room:#{data['room_id']}", message: data['message']
  end

  def declare_action(data)
    ActionCable.server.broadcast 'room_channel', message: data['message']
  end
end
