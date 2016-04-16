import requests
import logging
import httplib

host = 'http://localhost:3000/'
url = host + 'api/v1/'

def show_rooms(status=''):
  params = { 'status' : status }
  return get(url + 'rooms', params)

def create_player(name):
  params = { 'player' : { 'name' : name } }
  r = post(url + 'players', params)
  return r.json()

def create_room(name, max_round, player_num):
  params = { 'room' : { 'name' : name, 'max_round' : max_round, 'player_num' : player_num } }
  r = post(url + 'rooms', params)
  return r.json()

def destroy_player(pid):
  return delete(url + 'players/' + str(pid))

def destroy_room(rid):
  return delete(url + 'rooms/' + str(rid))

def setup_logging(log=True):
  if not log: return

  httplib.HTTPSConnection.debuglevel = 2

  logging.basicConfig()
  logging.getLogger().setLevel(logging.DEBUG)
  requests_log = logging.getLogger("requests.packages.urllib3")
  requests_log.setLevel(logging.DEBUG)
  requests_log.propagate = True

def get(url, params):
  response = requests.get(url, json=params)
  return log_response(response)

def post(url, params):
  response = requests.post(url, json=params)
  return log_response(response)

def delete(url):
  response = requests.delete(url)
  return log_response(response)

def log_response(response):
  print 'DEBUG:original:response body\n' + response.text + '\n'
  return response

if __name__ == '__main__':
  setup_logging()
  player = create_player('kota')
  room = create_room('pokapoka', 5, 3)
  show_rooms()
  destroy_room(room['id'])
  destroy_player(player['id'])

