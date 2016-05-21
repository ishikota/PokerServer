module RoundManagerSpecHelper

  def notification_msg(message)
    {
      "type" => "notification",
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

