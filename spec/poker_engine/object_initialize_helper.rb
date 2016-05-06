module ObjectInitializeHelper

    def create_player_with_pay_info(name, amount, status)
      player = PokerPlayer.new(name=name, 100)
      player.pay_info.update_by_pay(amount)
      if status == PokerPlayer::PayInfo::ALLIN
        player.pay_info.update_to_allin
      elsif status == PokerPlayer::PayInfo::FOLDED
        player.pay_info.update_to_fold
      end
      return player
    end

    def setup_player(pid=0, holecard=true)
      player = PokerPlayer.new(name=name(pid), 100)
      player.add_holecard(hole_card(pid)) if holecard
      return player
    end

    def setup_players(num, holecard=true)
      (1..num).reduce([]) { |ary, idx|
        ary << setup_player(idx-1, holecard)
      }
    end

    def setup_seats_with_players(player_num)
      seats = Seats.new
      setup_players(player_num).each { |player|
        seats.sitdown(player)
      }
      return seats
    end

    def setup_table_with_players(player_num)
      table = Table.new(cheat_deck)
      players = setup_players(player_num, hole_card=false)
      players.each { |player| table.seats.sitdown(player) }
      return table
    end

    def name(idx)
      ["hoge", "fuga", "boo"][idx]
    end

    def hole_card(idx)
      [
        [card(Card::CLUB, 9), card(Card::DIAMOND, 2)],
        [card(Card::CLUB, 8), card(Card::DIAMOND, 3)],
        [card(Card::CLUB, 10), card(Card::DIAMOND, 14)]
      ][idx]
    end

    def create_round_manager
      broadcaster = mock_broadcaster
      hand_evaluator = HandEvaluator.new
      game_evaluator = GameEvaluator.new(hand_evaluator)
      RoundManager.new(broadcaster, game_evaluator)
    end

    def mock_broadcaster
      broadcaster = double("broadcaster")
      allow(broadcaster).to receive(:notification)
      allow(broadcaster).to receive(:ask)
      return broadcaster
    end


    def card(suit, rank)
      Card.new(suit, rank)
    end

end

