require 'inifile'

# Constants for testing

CMD = 'wf'.freeze
TW = 180

ENDPOINT = 'metrics.wavefront.com'.freeze
TOKEN = '0123456789-ABCDEF'.freeze
RES_DIR = Pathname.new(__dir__) + 'wavefront-cli' + 'resources'
CF = RES_DIR + 'wavefront.conf'
CF_VAL =  IniFile.load(CF)
JSON_POST_HEADERS = {
  'Content-Type': 'application/json', Accept: 'application/json'
}.freeze
