import websocket

# json parameter
identifier = r'"identifier":"{\"channel\":\"RoomChannel\"}"'
cma = ' , '
command = '"command" : '
data = '"data" : '
action = r'\"action\" : '
auth_params = r'\"room_id\" : 1, \"user_id\" : 1, \"credencial\": \"fugafuga\"'

def on_message(ws, message):
    print message

def on_error(ws, error):
    print error

def on_close(ws):
    print "### closed ###"

def on_open(ws):
  while True:
    f = raw_input("s: subscribe, e: enter_room, m: send message, other: go listening loop")
    if f == 's':
      ws.send('{' + identifier + cma + command + '"subscribe"' + cma + data + '"{'+ auth_params +'}"'+ '}')
    elif f == 'e':
      ws.send('{' + identifier + cma + command + '"message"'   + cma + data + '"{'+ auth_params + cma + action + r'\"enter_room\"' + '}"' + '}')
    elif f == 'm':
      ws.send('{' + identifier + cma + command + '"message"'   + cma + data + '"{'+ auth_params + cma + action + r'\"speak_in_room\"' + cma +  r'\"message\" : \"hoge\"' + '}"' + '}')
    else:
      break


if __name__ == "__main__":
    websocket.enableTrace(True)
    ws = websocket.WebSocketApp("ws://localhost:3000/cable",
                              on_message = on_message,
                              on_error = on_error,
                              on_close = on_close)
    ws.on_open = on_open
    ws.run_forever()
