import websocket

from params_builder import ParamsBuilder
from message_handler import MessageHandler

# const
host = "ws://localhost:3000/cable"
room_id = 1
user_id = 1
credential = "fugafuga"

# helper
pb = ParamsBuilder(user_id, room_id, credential)
msg_handler = MessageHandler(pb)

# global
state = MessageHandler.CONNECTING

def on_message(ws, message):
  global state
  state = msg_handler.on_message(state, ws, message)

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
