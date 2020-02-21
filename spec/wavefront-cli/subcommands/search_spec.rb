#!/usr/bin/env ruby
# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/wavefront-cli/alert'
require_relative '../../../lib/wavefront-cli/subcommands/search'

class WavefrontCliSubcommandSearchTest < MiniTest::Test
  attr_reader :wf, :wf_cmd
  def setup
    cc = WavefrontCli::Alert.new(endpoint: 'test.wavefront.com',
                                 token: '0123456789-ABCDEF',
                                 debug: false,
                                 noop: true)

    @wf = WavefrontCli::Subcommand::Search.new(cc, {})
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
