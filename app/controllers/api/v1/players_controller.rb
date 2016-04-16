module Api
  module V1
    class PlayersController < ApplicationController

      PRIVATE_CONTENT_KEYS = ["credential", "created_at", "updated_at"]

      def create
        params = player_params.merge(credential: generate_credential)
        @player = Player.new(params)
        if @player.save
          render text: @player.attributes.reject!\
            { |k,v| PRIVATE_CONTENT_KEYS.include?(k) }.to_json
        else
          #hanle error
        end
      end

      def destroy
        player = Player.find(params[:id]).destroy
        res = {}\
          .merge!(msg_type: "resource_management")
          .merge!(action: "destroy_user")
          .merge!(status: "success")
          .merge!(message: "player [ #{player.name} ] is destroyed")

        render text: res.to_json
      end

      private

        def player_params
          params.require(:player).permit(:name)
        end

        def generate_credential
          SecureRandom.urlsafe_base64
        end
    end
  end
end

