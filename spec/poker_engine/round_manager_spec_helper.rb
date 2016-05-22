module RoundManagerSpecHelper

  def broadcast_msg(message)
    {
      "type" => "broadcast",
      "message" => message
    }
  end

  def ask_msg(recipient, message)
    {
      "type" => "ask",
      "recipient" => recipient,
      "message" => message
    }
  end

end

