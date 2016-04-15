import websocket

# const
host = "ws://localhost:3000/cable"
room_id = 1
user_id = 1
credencial = "fugafuga"

def on_message(ws, message):
    print message

def on_error(ws, error):
    print error

def on_close(ws):
    print "### closed ###"

def on_open(ws):
  while True:
    f = raw_input("s: subscribe, e: enter_room, m: send message, other: go listening loop")
    params = ''
    if f == 's':
      params = build_subscribe_params()
    elif f == 'e':
      params = build_message_params("enter_room")
    elif f == 'm':
      params = build_message_params("speak_in_room", { "message" : "hoge" })
    else:
      break
    ws.send(params)

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
