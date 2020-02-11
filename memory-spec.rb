require 'rspec-benchmark'
require_relative 'task-2.rb'

RSpec.describe "Memory testing" do
  it 'performs with RSS under 2 Mb on file with 100_000 lines' do
    memory_before = `ps -o rss= -p #{Process.pid}`.to_i / 1024

    puts "RSS size before programm execution: #{memory_before} Mb."
    puts "Start program execution."

    work('data_small.txt')

    memory_after = `ps -o rss= -p #{Process.pid}`.to_i / 1024
    puts "RSS size after programm execution: #{memory_before} Mb."

    memory_diff = memory_after - memory_before
    puts "Memory increase equals #{memory_diff} Mb."

    expect(memory_after - memory_before).to be <= 2
  end

  it 'performs with RSS under 70 Mb on file with 3_250_000 lines' do
    memory_before = `ps -o rss= -p #{Process.pid}`.to_i / 1024

    puts "RSS size before programm execution: #{memory_before} Mb."
    puts "Start program execution."

    work('data_large.txt')

    memory_after = `ps -o rss= -p #{Process.pid}`.to_i / 1024
    puts "RSS size after programm execution: #{memory_before} Mb."

    memory_diff = memory_after - memory_before
    puts "Memory increase equals #{memory_diff} Mb."

    expect(memory_after - memory_before).to be <= 70
  end
end
