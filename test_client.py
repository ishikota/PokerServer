import websocket

def on_message(ws, message):
    print message

def on_error(ws, error):
    print error

def on_close(ws):
    print "### closed ###"

def on_open(ws):
  while True:
    f = raw_input("s: subscribe, m: send message, other: go listening loop")
    if f == 's':
      ws.send(r'{"identifier":"{\"channel\":\"RoomChannel\"}", "command": "subscribe"}')
    else:
      ws.send(r'{"identifier" : "{\"channel\":\"RoomChannel\"}", "command": "message", "data": "{\"message\" : \"hoge\", \"action\" : \"declare_action\" }"}')


if __name__ == "__main__":
    websocket.enableTrace(True)
    ws = websocket.WebSocketApp("ws://localhost:3000/cable",
                              on_message = on_message,
                              on_error = on_error,
                              on_close = on_close)
    ws.on_open = on_open
    ws.run_forever()
