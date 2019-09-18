require 'json'
require_relative '../../constants'

# Load in a canned query response
#
def load_query_response
  load_file('sample_query_response.json')
end

def load_raw_query_response
  load_file('sample_raw_query_response.json')
end

def load_file(file)
  JSON.parse(IO.read(RES_DIR + file), symbolize_names: true)
end
