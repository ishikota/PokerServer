require 'rails_helper'

RSpec.describe RoomChannelDelegateHelper, :type => :helper do

  describe "setup_components_holder" do
    let(:room) { FactoryGirl.create(:room) }

    it "should setup dealer with proper component" do
      holder = helper.setup_components_holder(room)
      expect(holder[:broadcaster]).to be_a Broadcaster
      expect(holder[:config]).to be_a Config
      expect(holder[:table]).to be_a Table
      expect(holder[:round_manager]).to be_a RoundManager
      expect(holder[:action_checker]).to be_a ActionChecker
      expect(holder[:player_maker]).to be_a PlayerMaker
      expect(holder[:message_builder]).to be_a MessageBuilder
    end
  end

end

