import json
import time

class MessageHandler:

  # state
  CONNECTING = 0
  WAITING_DOOR_OPEN = 1
  WAITING_PLAYER_ARRIVAL = 2

  def __init__(self, params_builder): # pass lobby handler
    self.pb = params_builder

  # return state
  def on_message(self, state, ws, message):
    msg = json.loads(message)

    if msg['identifier'] == '_ping':
      return self.retry_request_if_needed(ws, state)

    if state == self.CONNECTING:
      if self.type_ping(msg): return state

      if self.type_confirm_subscription(msg):
        self.message_subscription_is_done()
        ws.send(self.pb.build_message_params("enter_room"))
        return self.forward_state(state)

    elif state == self.WAITING_DOOR_OPEN:
      msg = msg['message']

      if self.type_welcome(msg):
        self.message_welcome()
        return self.forward_state(state)

    elif state == self.WAITING_PLAYER_ARRIVAL:
      if self.type_ping(msg): return state
      msg = msg['message']
      if self.type_player_arrival(msg):
        self.message_member_arrival(msg)
      if self.type_ready():
        self.message_notify_ready()

    return state

  def message_subscription_is_done(self):
    print '[onMessage] your subscription request is accepted!!'
    print '[onMessage] So move to OPENING_DOOR state'
    print '[onMessage] now trying to enter poker room...'

  def message_welcome(self):
    print '[onMessage] you are in the room !! please wait for other player\'s arrival.'

  def message_member_arrival(self, msg):
    print '[onMessage] Player arrived!! ' + msg['message']

  def message_notify_ready(self):
    print '[onMessage] Hey!! Everything is ready!! Let\'s poker!!'

  def retry_request_if_needed(self, ws, state):
    if state == self.WAITING_DOOR_OPEN:
      print '[onMessage] retry enter_room request'
      ws.send(self.pb.build_message_params("enter_room"))
      time.sleep(1)
    return state

  def type_ping(self, msg):
    return msg['identifier'] == '_ping'

  def type_confirm_subscription(self, msg):
    return msg['identifier'] == '{"channel":"RoomChannel"}' and \
        msg['type'] == 'confirm_subscription'

  def type_player_arrival(self, msg):
    return msg['phase'] == 'member_wanted' and msg['type'] == 'arrival'

  def type_welcome(self, msg):
    return msg['phase'] == 'member_wanted' and msg['type'] == 'welcome'

  def type_ready(self, msg):
    return msg['phase'] == 'member_wanted' and msg['type'] == 'ready'

  def forward_state(self, state):
    return state + 1

