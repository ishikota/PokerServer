# Be sure to restart your server when you modify this file. Action Cable runs in an EventMachine loop that does not support auto reloading.
class RoomChannel < ApplicationCable::Channel
  unloadable
  include RoomChannelHelper

  def subscribed
    # stream_from "some_channel"
  end

  def unsubscribed
    get_delegate.exit_room(uuid)
  end

  def enter_room(data)
    get_delegate.enter_room(uuid, data)
  end

  def declare_action(data)
    room = Room.find(data['room_id'])
    player = Player.find(data['player_id'])
    # TODO fetch dealer from hash and resume_round with passed data
    ActionCable.server.broadcast "room:#{room.id}:#{player.id}", action_accept_message
  end


  private

    def get_delegate
      @delegate || create_delegate
    end

    def create_delegate
      channel_wrapper = ChannelWrapper.new(self)
      message_builder = MessageBuildHelper.new
      @delegate = RoomChannelDelegate.new(channel_wrapper, message_builder)
    end

    def action_accept_message
      {}.merge!(phase: "player_poker")\
        .merge!(type: "accept")\
        .merge!(type: "action accepted")
    end

end
