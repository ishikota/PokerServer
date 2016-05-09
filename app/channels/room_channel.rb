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
    get_delegate.declare_action(data)
  end


  private

    def get_delegate
      @delegate || create_delegate
    end

    def create_delegate
      channel_wrapper = ChannelWrapper.new(self)
      message_builder = MessageBuildHelper.new
      dealer_maker = DealerMaler.new
      @delegate = RoomChannelDelegate.new(channel_wrapper, message_builder, dealer_maker)
    end

end
