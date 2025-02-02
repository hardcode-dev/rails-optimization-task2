# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/reporter'


class TestMe < Minitest::Test
  def setup
    @result_path = 'tests/result.json'
    File.write(@result_path, '')
  end

  def test_result
    work('tests/fixtures/data.txt', @result_path, { watcher_enable: true })
    expected_result = JSON.parse(File.read('tests/fixtures/expected_json.json'))
    result = JSON.parse(File.read(@result_path))
    assert_equal expected_result['usersStats'], result['usersStats']
    assert_equal expected_result['allBrowsers'], result['allBrowsers']
    assert_equal expected_result['totalUsers'], result['totalUsers']
    assert_equal expected_result['uniqueBrowsersCount'], result['uniqueBrowsersCount']
    assert_equal expected_result['totalSessions'], result['totalSessions']
    File.delete(@result_path)
  end
end