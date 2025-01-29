require 'rspec-benchmark'
require_relative '../task-2.rb'

RSpec.describe "Memory testing" do


  it do


    mem_start = `ps -o rss= -p #{Process.pid}`.to_i / 1024
    Work.new('data_large.txt').work

    mem_end = `ps -o rss= -p #{Process.pid}`.to_i / 1024

    mem_raise = mem_end - mem_start

    expect(mem_raise).to be <= 20


  end
end