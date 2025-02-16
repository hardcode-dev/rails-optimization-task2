# frozen_string_literal: true

require 'rspec'
require_relative 'task-2'

RSpec.describe 'Memory usage' do
  before { File.write('result.json', '') }

  it 'consumes no more than 70MB of memory' do
    memory_before = `ps -o rss= -p #{Process.pid}`.to_i / 1024

    work('data_large.txt', true)

    memory_after = `ps -o rss= -p #{Process.pid}`.to_i / 1024
    memory_usage = memory_after - memory_before

    puts "Memory usage during test: #{memory_usage} MB"
    expect(memory_usage).to be <= 70
  end
end

