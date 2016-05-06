module ObjectInitializeHelper

    def setup_player
      hole_card = [card(Card::CLUB, 10), card(Card::DIAMOND, 14) ]
      player = create_player("hoge")
      player.add_holecard(hole_card)
      player.add_action_history(PokerPlayer::ACTION::RAISE, 10, 5)
      player.pay_info.update_by_pay(10)
      return player
    end

    def setup_seats_with_players
      seats = Seats.new
      create_players(2).each { |player|
        seats.sitdown(player)
      }
      return seats
    end

    def setup_table(player_num)
      table = Table.new(cheat_deck)
      players = create_players(player_num)
      players.each { |player| table.seats.sitdown(player) }
      return table
    end

    def setup_table_with_action_histories(player_num)
      table = Table.new
      players = create_players(player_num)
      players.each { |player| table.seats.sitdown(player) }
      players[0].add_action_history(PokerPlayer::ACTION::RAISE, 10, 5)
      players[1].add_action_history(PokerPlayer::ACTION::FOLD)
      players[2].add_action_history(PokerPlayer::ACTION::RAISE, 20, 10)
      players[0].add_action_history(PokerPlayer::ACTION::CALL, 20)
      return table
    end

    def setup_round_manager
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

    def create_players(num)
      names = ["hoge", "fuga", "bar"]
      names.take(num).each.reduce([]) { |ary, name|
        ary << create_player(name)
      }
    end

    def create_player(name)
      PokerPlayer.new(name=name, 100)
    end

    def create_player_with_pay_info(name, amount, status)
      player = create_player(name)
      player.pay_info.update_by_pay(amount)
      if status == PokerPlayer::PayInfo::ALLIN
        player.pay_info.update_to_allin
      elsif status == PokerPlayer::PayInfo::FOLDED
        player.pay_info.update_to_fold
      end
      return player
    end

    def card(suit, rank)
      Card.new(suit, rank)
    end

end

