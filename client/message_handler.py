import json
import time

class MessageHandler:

  # state
  CONNECTING = 0
  WAITING_DOOR_OPEN = 1
  WAITING_PLAYER_ARRIVAL = 2

  def __init__(self, params_builder):
    self.pb = params_builder

  # return state
  def on_message(self, state, ws, message):
    msg = json.loads(message)

    # resend if required response does not come
    # TODO do not just resend but should rollback state before resend
    if msg['identifier'] == '_ping':
      if state == self.WAITING_DOOR_OPEN:
        ws.send(self.pb.build_message_params("enter_room"))
        time.sleep(1)
      return state

    if state == self.CONNECTING:
      if msg['identifier'] == '_ping': return
      if msg['identifier'] == '{"channel":"RoomChannel"}' and msg['type'] == 'confirm_subscription':
        print '[onMessage] your subscription request is accepted!!'
        print '[onMessage] So move to OPENING_DOOR state'
        print '[onMessage] now trying to enter poker room...'
        ws.send(self.pb.build_message_params("enter_room"))
        state += 1
    elif state == self.WAITING_DOOR_OPEN:
      msg = msg['message']
      if msg['phase'] == 'member_wanted' and msg['type'] == 'welcome':
        print '[onMessage] you are in the room !! please wait for other player\'s arrival.'
        state += 1
    elif state == self.WAITING_PLAYER_ARRIVAL:
      if msg['identifier'] == '_ping': return
      msg = msg['message']
      if msg['phase'] == 'member_wanted' and msg['type'] == 'arrival':
        print '[onMessage] Player arrived!! ' + msg['message']
      if msg['phase'] == 'member_wanted' and msg['type'] == 'ready':
        print '[onMessage] Hey!! Everything is ready!! Let\'s poker!!'

    return state

