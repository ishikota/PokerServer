class DataBridge

  def initialize(dealer, broadcaster)
    @dealer = dealer
    @broadcaster = broadcaster
  end

  def run
    @dealer.setup
    receive_data(start_message)
  end

  def receive_data(data)
    ask_data = @dealer.run_until_ask_action(data)
    @broadcaster.ask(ask_data[:player_id], ask_data[:data])
  end

  private

    def start_message
      "TODO START MESSAGE"
    end

end

