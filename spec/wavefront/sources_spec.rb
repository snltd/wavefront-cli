#
# Due to dependency requirements, webmock does not work with Ruby
# 1.9.3. For as long as we have to support that, it's off the table.
#
require_relative '../../spec_helper'
#require 'webmock/rspec'

opts = {
  token:    TEST_TOKEN,
  endpoint: TEST_HOST,
}

describe Wavefront::Cli::Sources do
  attr_reader :wf, :host, :path, :headers, :post_headers

  before do
    @wf = Wavefront::Cli::Sources.new(opts, nil)
    @wf.setup_wf
    @host = Wavefront::Metadata::DEFAULT_HOST
    @path = Wavefront::Metadata::DEFAULT_PATH
    @headers = { :'X-AUTH-TOKEN' => TEST_TOKEN }
    @post_headers =headers.merge(
      { :'Content-Type' => 'text/plain', :Accept => 'application/json' })

  end

  #describe '#list_source_handler' do
    #it 'makes API request with default options' do
      #stub_request(:get, "https://metrics.wavefront.com/api/manage/source/?desc=false&limit=100&pattern=mysource").
      #with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby', 'X-Auth-Token'=>'test'}).
      #to_return(:status => 200, :body => "{}", :headers => {})
      #wf.list_source_handler('mysource',)
      #expect(wf).to receive(:display_data).with('list_source', '')
    #end

    #it 'handles an invalid source' do
      #expect{wf.show_source('!INVALID!')}.
        #to raise_exception(Wavefront::Exception::InvalidSource)
    #end
  #end
end
