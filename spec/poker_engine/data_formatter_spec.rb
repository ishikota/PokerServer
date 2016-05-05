require 'rails_helper'

RSpec.describe DataFormatter do

  let(:formatter) { DataFormatter.new }

  describe "player" do
    let(:player) { setup_player }

    it "should convert player into hash" do
      data = formatter.format_player(player)
      expect(data["name"]).to eq "hoge"
      expect(data["stack"]).to eq 100
      expect(data["state"]).to eq 0
      expect(data["hole_card"]).to be_nil
      expect(data["action_histories"]).to be_nil
      expect(data["pay_info"]).to be_nil
    end

    context "with holecard" do

      it "should include hole card" do
        data = formatter.format_player(player, holecard=true)
        expect(data["hole_card"]).to eq ["CT", "DA"]
      end
    end

  end

  describe "seat" do
    let(:seats) { setup_seats_with_players }

    it "should convert seats into hash" do
      data = formatter.format_seats(seats)
      expect(data["seats"].size).to eq 2
      expect(data["seats"].first).to eq formatter.format_player(seats.players.first)
    end
  end

  describe "game_information" do
    let(:seats) { setup_seats_with_players }
    let(:config) { Config.new }

    it "should convert game_information into hash" do
      data = formatter.format_game_information(config, seats)
      expect(data["player_num"]).to eq 2
      expect(data["seats"]).to eq formatter.format_seats(seats)
      expect(data["rule"]["small_blind_amount"]).to eq 5
      expect(data["rule"]["max_round"]).to eq 10
      expect(data["rule"]["initial_stack"]).to eq 100
    end

  end


  private

    def setup_player
      hole_card = [card(Card::CLUB, 10), card(Card::DIAMOND, 14) ]
      player = PokerPlayer.new(name="hoge", 100)
      player.add_holecard(hole_card)
      player.add_action_history(PokerPlayer::ACTION::RAISE, 10, 5)
      player.pay_info.update_by_pay(10)
      return player
    end

    def setup_seats_with_players
      seats = Seats.new
      seats.sitdown(PokerPlayer.new(name="hoge", 100))
      seats.sitdown(PokerPlayer.new(name="fuga", 100))
      return seats
    end

    def card(suit, rank)
      Card.new(suit, rank)
    end

end

