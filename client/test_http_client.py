from http_client import CustomHttpClient

host = 'http://localhost:3000/'
url = host + 'api/v1/'

c = CustomHttpClient()

def show_rooms(status=''):
  params = { 'status' : status }
  return c.get(url + 'rooms', params)

def create_player(name):
  params = { 'player' : { 'name' : name } }
  r = c.post(url + 'players', params)
  return r.json()

def create_room(name, max_round, player_num):
  params = { 'room' : { 'name' : name, 'max_round' : max_round, 'player_num' : player_num } }
  r = c.post(url + 'rooms', params)
  return r.json()

def destroy_player(pid):
  return c.delete(url + 'players/' + str(pid))

def destroy_room(rid):
  return c.delete(url + 'rooms/' + str(rid))

if __name__ == '__main__':
  player = create_player('kota')
  room = create_room('pokapoka', 5, 3)
  show_rooms()
  destroy_room(room['id'])
  destroy_player(player['id'])

