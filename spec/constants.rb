require 'pathname'
require 'inifile'

# Constants for testing

ROOT = Pathname.new(__dir__).parent

CMD = 'wf'.freeze
TW = 80

ENDPOINT = 'metrics.wavefront.com'.freeze
TOKEN = '0123456789-ABCDEF'.freeze
RES_DIR = ROOT + 'spec' + 'wavefront-cli' + 'resources'
CF = RES_DIR + 'wavefront.conf'
CF_VAL =  IniFile.load(CF)
JSON_POST_HEADERS = {
  'Content-Type': 'application/json', Accept: 'application/json'
}.freeze
TEE_ZERO = Time.now.freeze
