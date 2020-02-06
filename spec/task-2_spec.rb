require "spec_helper"
require "rspec-benchmark"

require_relative "../task-2"

describe Report do
  include RSpec::Benchmark::Matchers

  context "when data.txt file" do
    let(:file) { file_fixture("data/data.txt") }
    let(:file_path) { file.path }
    let(:file_result) { file.read }
    let(:report) { Report.new(file_path) }
    let(:result_file) { File.open(File.join(ENV["PWD"], "result.json")) }
    let(:result_fixture) { file_fixture("result/data.json").read }

    it "should be valid" do
      report.work

      expect(result_file.read).to eq(result_fixture)
    end
  end

  context "when data_10.txt file" do
    let(:file) { file_fixture("data/data_10.txt") }
    let(:file_path) { file.path }
    let(:report) { Report.new(file_path) }
    let(:start_memory) { ("MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)).to_i }

    it "should not use more than 20mb memorys" do
      report.work

      end_memory = ("MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)).to_i
      mem_diff = end_memory - start_memory

      expect(mem_diff).to be <= 40
    end
  end
end
