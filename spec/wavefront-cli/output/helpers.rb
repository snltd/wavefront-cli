# frozen_string_literal: true

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
  JSON.parse(File.read(RES_DIR.join(file)), symbolize_names: true)
end
