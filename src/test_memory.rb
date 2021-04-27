# frozen_string_literal: true

require "minitest/autorun"

require_relative 'work.rb'

class TestMemory < Minitest::Test
  MEMORY_EXPECTATION_MB = 70

  def setup
    File.write('result.json', '')
  end

  def test_memory
    perform
    memory = `ps -o rss= -p #{Process.pid}`.to_i / 1024
    assert_operator memory, :<=, MEMORY_EXPECTATION_MB,
                    "Memory consumption (#{memory}Mb) is higher than #{MEMORY_EXPECTATION_MB}Mb"
  end

  private

  def perform
    work(file_name: 'data_large.txt', progress_bar: false)
  end
end