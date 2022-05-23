require 'benchmark/ips'

require_relative './benchmark_helper.rb'
require_relative '../task-2.rb'

suite = GCSuite.new
Benchmark.ips do |bm|
  bm.config(
    suite: suite,
    stats: :bootstrap,
    confidence: 95
  )

  bm.report('1000') { work('./benchmark/support/data_1k.txt') }
  bm.report('2000') { work('./benchmark/support/data_2k.txt') }
  bm.report('4000') { work('./benchmark/support/data_4k.txt') }
  bm.report('8000') { work('./benchmark/support/data_8k.txt') }
  bm.report('16000') { work('./benchmark/support/data_16k.txt') }
end
