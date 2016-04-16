import websocket
import json
import time

from params_builder import ParamsBuilder

# const
host = "ws://localhost:3000/cable"
room_id = 1
user_id = 1
credential = "fugafuga"

# state
CONNECTING = 0
WAITING_DOOR_OPEN = 1
WAITING_PLAYER_ARRIVAL = 2

# helper
pb = ParamsBuilder(user_id, room_id, credential)

state = CONNECTING

def on_message(ws, message):
  global state
  msg = json.loads(message)

  # resend if required response does not come
  # TODO do not just resend but should rollback state before resend
  if msg['identifier'] == '_ping':
    if state == WAITING_DOOR_OPEN:
      ws.send(pb.build_message_params("enter_room"))
      time.sleep(1)
    return

  if state == CONNECTING:
    if msg['identifier'] == '_ping': return
    if msg['identifier'] == '{"channel":"RoomChannel"}' and msg['type'] == 'confirm_subscription':
      print '[onMessage] your subscription request is accepted!!'
      print '[onMessage] So move to OPENING_DOOR state'
      print '[onMessage] now trying to enter poker room...'
      ws.send(pb.build_message_params("enter_room"))
      state += 1
  elif state == WAITING_DOOR_OPEN:
    msg = msg['message']
    if msg['phase'] == 'member_wanted' and msg['type'] == 'welcome':
      print '[onMessage] you are in the room !! please wait for other player\'s arrival.'
      state += 1
  elif state == WAITING_PLAYER_ARRIVAL:
    if msg['identifier'] == '_ping': return
    msg = msg['message']
    if msg['phase'] == 'member_wanted' and msg['type'] == 'arrival':
      print '[onMessage] Player arrived!! ' + msg['message']
    if msg['phase'] == 'member_wanted' and msg['type'] == 'ready':
      print '[onMessage] Hey!! Everything is ready!! Let\'s poker!!'

def on_error(ws, error):
    print error

def on_close(ws):
    print "### closed ###"

def on_open(ws):
  ws.send(pb.build_subscribe_params())

if __name__ == "__main__":
    websocket.enableTrace(True)
    ws = websocket.WebSocketApp(host,
                              on_message = on_message,
                              on_error = on_error,
                              on_close = on_close)
    ws.on_open = on_open
    ws.run_forever()
