import websocket
import json
import time

# const
host = "ws://localhost:3000/cable"
room_id = 1
user_id = 1
credencial = "fugafuga"

# state
CONNECTING = 0
WAITING_DOOR_OPEN = 1
WAITING_PLAYER_ARRIVAL = 2


state = CONNECTING

def on_message(ws, message):
  global state
  msg = json.loads(message)

  if state == CONNECTING:
    if msg['identifier'] == '_ping': return
    if msg['identifier'] == '{"channel":"RoomChannel"}' and msg['type'] == 'confirm_subscription':
      print '[onMessage] your subscription request is accepted!!'
      print '[onMessage] So move to OPENING_DOOR state'
      print '[onMessage] now trying to enter poker room...'
      ws.send(build_message_params("enter_room"))
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
  ws.send(build_subscribe_params())

def build_subscribe_params():
  return build_my_params("subscribe")

def build_message_params(action, data={}):
  return build_my_params("message", action, data)

def build_my_params(command, action = '', data={}):
  return build_params(room_id, user_id, credencial, command, action, data)

def build_params(room_id, user_id, credencial, command, action = '', data={}):
  return \
     '{' + \
        r'"identifier":"{\"channel\":\"RoomChannel\"}"' + ' , '\
        r'"command" : "' + command + '" , ' + \
        r'"data" : "{' + \
          build_action(action) + \
          build_data(data) + \
          r'\"room_id\"    : ' + str(room_id)    + ' , ' + \
          r'\"user_id\"    : ' + str(user_id)    + ' , ' + \
          r'\"credencial\" : \"' + credencial +  r'\"'\
        r'}"' + \
      '}'

def build_action(act):
  if act == '':
    return act
  else:
    return r'\"action\" : ' + r'\"' + act + r'\" , '

def build_data(dt):
  items = [r'\"' + key + r'\"' + ' : ' + r'\"' + val + r'\"' for key, val in dt.items()]
  params = ' , '.join(items)
  if params != '':
    params = params + ' , '
  return params

if __name__ == "__main__":
    websocket.enableTrace(True)
    ws = websocket.WebSocketApp(host,
                              on_message = on_message,
                              on_error = on_error,
                              on_close = on_close)
    ws.on_open = on_open
    ws.run_forever()
