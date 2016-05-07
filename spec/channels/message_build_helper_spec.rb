require 'rails_helper'

RSpec.describe MessageBuildHelper do

  let(:helper) { MessageBuildHelper.new }

  describe "#build_welcome_message" do

    it "should build welcome message" do
      msg = helper.build_welcome_message
      expect(msg[:phase]).to eq MessageBuildHelper::Phase::MEMBER_WANTED
      expect(msg[:type]).to eq MessageBuildHelper::Type::WELCOME
    end
  end

  describe "#build_member_arrival_message" do
    let(:room) { double("room") }
    let(:arrived_player) { double("player") }

    before {
      allow(arrived_player).to receive(:name).and_return "hoge"
      allow(room).to receive(:player_num).and_return 2
      allow(room).to receive_message_chain('players.size').and_return 1
    }

    it "should build member arrival message" do
      msg = helper.build_member_arrival_message(room, arrived_player)
      expect(msg[:phase]).to eq MessageBuildHelper::Phase::MEMBER_WANTED
      expect(msg[:type]). to eq MessageBuildHelper::Type::MEMBER_ARRIVAL
      expect(msg[:message]).to match(/hoge/)
      expect(msg[:message]).to match(/1 more players/)
    end
  end

  describe "#build_start_poker_message" do

    it "should build ready message" do
      msg = helper.build_start_poker_message
      expect(msg[:phase]).to eq MessageBuildHelper::Phase::MEMBER_WANTED
      expect(msg[:type]).to eq MessageBuildHelper::Type::READY
      expect(msg[:message]).to match(/Let's start poker!!/)
    end
  end

end
