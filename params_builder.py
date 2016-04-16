class ParamsBuilder:


  def __init__(self, player_id, room_id, credential):
    self.player_id = player_id
    self.room_id = room_id
    self.credential = credential

  def build_subscribe_params(self):
    return self.build_my_params("subscribe")

  def build_message_params(self, action, data={}):
    return self.build_my_params("message", action, data)

  def build_my_params(self, command, action = '', data={}):
    return self.build_params(self.room_id, self.player_id, self.credential,\
        command, action, data)

  def build_params(self, room_id, player_id, credential, command, action = '', data={}):
    return \
       '{' + \
          r'"identifier":"{\"channel\":\"RoomChannel\"}"' + ' , '\
          r'"command" : "' + command + '" , ' + \
          r'"data" : "{' + \
            self.build_action(action) + \
            self.build_data(data) + \
            r'\"room_id\"    : ' + str(room_id)    + ' , ' + \
            r'\"user_id\"    : ' + str(player_id)    + ' , ' + \
            r'\"credential\" : \"' + credential +  r'\"'\
          r'}"' + \
        '}'

  def build_action(self, action):
    if action == '':
      return action
    else:
      return r'\"action\" : ' + r'\"' + action + r'\" , '

  def build_data(self, data):
    items = [r'\"' + key + r'\"' + ' : ' + r'\"' + val + r'\"' for key, val in data.items()]
    params = ' , '.join(items)
    if params != '':
      params = params + ' , '
    return params

