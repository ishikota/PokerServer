module Api
  module V1

    class RoomsController < ApplicationController

      PRIVATE_CONTENT_KEYS = ["created_at", "updated_at"]

      def create
        @room = Room.new(room_params)
        if @room.save
          render text: @room.attributes.reject! \
            { |k,v| PRIVATE_CONTENT_KEYS.include?(k) }.to_json
        else
          #handle error
        end
      end

      def destroy
      end

      private

        def room_params
          params.require(:room).permit(:name, :max_round, :player_num)
        end

    end

  end
end
