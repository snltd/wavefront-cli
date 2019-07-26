require 'inifile'

# Constants for testing

CMD = 'wf'
TW = 80
DUMMY_RESPONSE = '{"status":{"result":"OK","message":"","code":200}'
ENDPOINT = 'metrics.wavefront.com'.freeze
TOKEN = '0123456789-ABCDEF'.freeze
RES_DIR = Pathname.new(__dir__) + 'wavefront-cli' + 'resources'
CF = RES_DIR + 'wavefront.conf'
CF_VAL =  IniFile.load(CF)
JSON_POST_HEADERS = {
    'Content-Type': 'application/json', Accept: 'application/json'
  }.freeze
