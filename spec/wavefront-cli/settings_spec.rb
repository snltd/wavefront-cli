#!/usr/bin/env ruby

require_relative '../support/command_base'
require_relative '../../lib/wavefront-cli/settings'

# Tests for the settings command
#
class SettingsEndToEndTest < EndToEndTest
  def test_list_permissions
    quietly do
      assert_cmd_gets('list permissions', '/api/v2/customer/permissions')
    end

    assert_abort_on_missing_creds('list permissions')
    assert_usage('list')
    assert_noop('list permissions',
                'uri: GET https://default.wavefront.com/api/v2/' \
                'customer/permissions')
  end

  def test_show_preferences
    quietly do
      assert_cmd_gets('show preferences', '/api/v2/customer/preferences')
    end

    assert_abort_on_missing_creds('show preferences')
    assert_noop('show preferences',
                'uri: GET https://default.wavefront.com/api/v2/' \
                'customer/preferences')
  end

  def test_default_usergroups
    quietly do
      assert_cmd_gets('default usergroups',
                      '/api/v2/customer/preferences/defaultUserGroups')
    end

    assert_abort_on_missing_creds('default usergroups')
    assert_noop('default usergroups',
                'uri: GET https://default.wavefront.com/api/v2/' \
                'customer/preferences/defaultUserGroups')
  end

  private

  def cmd_word
    'settings'
  end
end
