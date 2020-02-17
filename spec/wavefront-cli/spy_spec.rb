#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../support/command_base'
require_relative '../../lib/wavefront-cli/spy'

# Ensure 'spy' commands produce the correct API calls.
#
class SpyEndToEndTest < EndToEndTest
  def test_points
    capture_io do
      assert_cmd_gets('points', '/api/spy/points?sampling=0.01')
      assert_cmd_gets('points -r 0.02', '/api/spy/points?sampling=0.02')
      assert_cmd_gets('points -p mtc1',
                      '/api/spy/points?sampling=0.01&metric=mtc1')
      assert_cmd_gets('points -T tag1 -T tag2',
                      '/api/spy/points?sampling=0.01&pointTagKey=tag1' \
                      '&pointTagKey=tag2')
      assert_cmd_gets('points -p mtc1 -H host1',
                      '/api/spy/points?sampling=0.01&metric=mtc1&host=host1')
    end

    assert_exits_with('Sampling rates must be between 0 and 0.05.',
                      'points -r 0.7')
  end

  def test_histograms
    capture_io do
      assert_cmd_gets('histograms', '/api/spy/histograms?sampling=0.01')
      assert_cmd_gets('histograms -r 0.02', '/api/spy/histograms?sampling=0.02')
      assert_cmd_gets('histograms -p hst1',
                      '/api/spy/histograms?sampling=0.01&histogram=hst1')
      assert_cmd_gets('histograms -T tag1 -T tag2',
                      '/api/spy/histograms?sampling=0.01' \
                      '&histogramTagKey=tag1&histogramTagKey=tag2')
      assert_cmd_gets('histograms -p hst1 -H host1',
                      '/api/spy/histograms?sampling=0.01&histogram=hst1' \
                      '&host=host1')
    end

    assert_exits_with('Sampling rates must be between 0 and 0.05.',
                      'histograms -r 4')
  end

  def test_spans
    capture_io do
      assert_cmd_gets('spans', '/api/spy/spans?sampling=0.01')
      assert_cmd_gets('spans -r 0.02', '/api/spy/spans?sampling=0.02')
      assert_cmd_gets('spans -p span1',
                      '/api/spy/spans?sampling=0.01&name=span1')
      assert_cmd_gets('spans -T tag1 -T tag2',
                      '/api/spy/spans?sampling=0.01' \
                      '&spanTagKey=tag1&spanTagKey=tag2')
      assert_cmd_gets('spans -p span1 -H host1',
                      '/api/spy/spans?sampling=0.01&name=span1' \
                      '&host=host1')
    end

    assert_exits_with('Sampling rates must be between 0 and 0.05.',
                      'spans -r 7')
  end

  def test_ids
    capture_io do
      assert_cmd_gets('ids', '/api/spy/ids?sampling=0.01')
      assert_cmd_gets('ids -r 0.02', '/api/spy/ids?sampling=0.02')
      assert_cmd_gets('ids -p id1', '/api/spy/ids?sampling=0.01&name=id1')
      assert_cmd_gets('ids -y METRIC -p id1',
                      '/api/spy/ids?sampling=0.01' \
                      '&type=METRIC&name=id1')
    end

    assert_exits_with('Sampling rates must be between 0 and 0.05.',
                      'ids -r 7')
  end

  private

  def cmd_word
    'spy'
  end
end
