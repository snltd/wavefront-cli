#!/usr/bin/env ruby

require 'minitest/autorun'
require_relative '../../lib/wavefront-cli/alert'
require_relative '../../lib/wavefront-cli/version'

# Since I tidied up the file layout in wavefront-sdk, there's no
# longer a 1:1 mapping of CLI and SDK classes. wavefront-sdk/base is
# now wavefront-sdk/core/api. The only thing that broke was the
# tests in this class. Now we test the methods in the abstract base
# class via an instantiation of a concrete class. I don't think any
# of this matters.
#
class WavefrontCliBaseTest < MiniTest::Test
  attr_reader :wf, :wf_cmd

  def setup
    @wf = WavefrontCli::Alert.new(endpoint: 'test.wavefront.com',
                                  token:    '0123456789-ABCDEF',
                                  debug:    false,
                                  noop:     true)
  end

  def test_mk_creds
    assert_equal({ endpoint: 'test.wavefront.com',
                   token:    '0123456789-ABCDEF',
                   agent:    "wavefront-cli-#{WF_CLI_VERSION}" },
                 wf.mk_creds)
  end

  def test_dispatch
    assert_raises(WavefrontCli::Exception::UnhandledCommand) { wf.dispatch }
  end

  def test_conds_to_query
    assert_equal([{ key: 'mykey',
                    value: 'myvalue',
                    matchingMethod: 'EXACT',
                    negated: false }],
                 wf.conds_to_query(%w[mykey=myvalue]))

    assert_equal([{ key: 'mykey',
                    value: 'myvalue',
                    matchingMethod: 'EXACT',
                    negated: true }],
                 wf.conds_to_query(%w[mykey!=myvalue]))

    assert_equal([{ key: 'mykey',
                    value: 'myvalue',
                    matchingMethod: 'CONTAINS',
                    negated: true }],
                 wf.conds_to_query(%w[mykey!~myvalue]))

    assert_equal([{ key: 'mykey',
                    value: 'myvalue',
                    matchingMethod: 'STARTSWITH',
                    negated: false }],
                 wf.conds_to_query(%w[mykey^myvalue]))

    assert_equal([{ key: 'mykey',
                    value: 'myvalue',
                    matchingMethod: 'EXACT',
                    negated: true }],
                 wf.conds_to_query(%w[mykey!=myvalue]))

    assert_raises(WavefrontCli::Exception::UnparseableSearchPattern) do
      wf.conds_to_query(%w[what!nonsense])
    end
  end

  def test_matching_method
    assert_equal({ matchingMethod: 'EXACT', negated: true },
                 wf.matching_method('key!=val'))
    assert_equal({ matchingMethod: 'EXACT', negated: false },
                 wf.matching_method('key=val'))
    assert_equal({ matchingMethod: 'STARTSWITH', negated: false },
                 wf.matching_method('key^val'))
    assert_equal({ matchingMethod: 'STARTSWITH', negated: true },
                 wf.matching_method('key!^val'))
    assert_equal({ matchingMethod: 'CONTAINS', negated: false },
                 wf.matching_method('key~val'))
    assert_equal({ matchingMethod: 'CONTAINS', negated: true },
                 wf.matching_method('key!~val'))
    assert_raises(WavefrontCli::Exception::UnparseableSearchPattern) do
      wf.matching_method('what nonsense')
    end
  end
end
