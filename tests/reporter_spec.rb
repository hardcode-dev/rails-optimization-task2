require 'rspec-benchmark'
require_relative "../lib/reporter"


RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance reporter' do
  let(:file_path) { 'tests/fixtures/data.txt' }
  let(:result_path) { 'tests/result.json' }

  after do
    File.delete(result_path)
  end
  
  it 'create report' do
    expect {
      work(file_path, result_path, { watcher_enable: true })
    }.to perform_allocation(70_000).bytes
  end  
end
