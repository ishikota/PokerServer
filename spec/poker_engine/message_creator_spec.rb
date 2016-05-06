require 'rails_helper'
require 'features/feature_spec_helper'
require 'poker_engine/object_initialize_helper'

RSpec.describe MessageCreator do
  include FeatureSpecHelper
  include ObjectInitializeHelper

  let(:game_evaluator) { GameEvaluator.new(hand_evaluator=nil) }
  let(:formatter) { DataFormatter.new(game_evaluator) }
  let(:message_creator) { MessageCreator.new(formatter) }

  describe "game_start_message" do
    let(:seats) { setup_seats_with_players(2) }
    let(:config) { Config.new }

    it "should create correct message" do
      game_info_ans = formatter.format_game_information(config, seats)
      msg = message_creator.game_start_message(config, seats)
      expect(msg["message_type"]).to eq MessageCreator::Type::GAME_START_MESSAGE
      expect(msg["game_information"]).to eq game_info_ans
    end
  end

  describe "round_start_message" do
    let(:seats) { setup_seats_with_players(2) }

    it "should create correct message for correct player" do
      msg = message_creator.round_start_message(player_pos=1, seats)
      expect(msg["message_type"]).to eq MessageCreator::Type::ROUND_START_MESSAGE
      expect(msg["seats"]).to eq formatter.format_seats(seats)
      expect(msg["hole_card"]).to eq ["C8", "D3"]
    end
  end

  describe "street_start_message" do
    let(:round_manager) { create_round_manager }
    let(:table) { setup_table_with_players(2) }

    before {
      action_checler = ActionChecker.new
      round_manager.start_new_round(table)
      round_manager.apply_action(table, 'call', 10, action_checler)  # forward to FLOP
    }

    it "should create correct message" do
      msg = message_creator.street_start_message(round_manager, table)
      expect(msg["message_type"]).to eq MessageCreator::Type::STREET_START_MESSAGE
      expect(msg["street"]).to eq "FLOP"
      expect(msg["round_state"]).to eq formatter.format_round_state(round_manager, table)
    end
  end

end

