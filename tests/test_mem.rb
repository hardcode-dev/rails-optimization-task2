require 'rspec-benchmark'
require_relative '../task-2'

RSpec.configure do |config|
    config.include RSpec::Benchmark::Matchers
end

def process_mem_mb pid
    (`ps -o rss= -p #{pid}`.to_i / 1024)
end

MAX_TOTAL_OBJECTS = 500000
MAX_MEMORY_MB = 70
DATA_SIZE = 50000

describe 'Work memory allocation' do

    it 'create not more than 500_000 object with disable GC' do
        work("data/data#{DATA_SIZE}.txt", true)
        expect(ObjectSpace.count_objects[:TOTAL]).to be < MAX_TOTAL_OBJECTS
    end

    it 'consumes not more than memory budget(70 mb)' do 
        pid = Process.fork do
            work("data/data#{DATA_SIZE}.txt", false)
        end
        expect(process_mem_mb(pid)).to be < MAX_MEMORY_MB # actually if took around 39 in tests but budget is 70
        Process.waitall
    end
    
    # тест ниже работает оч медленно, видимо benchmark-malloc внтури проводит манипуляции с GC
    # в теории можно использовать его вместо проверки поля ObjectSpace.count_objects[:TOTAL]
    #  it 'bench malloc' do
    #  expect {
    #     work("data/data#{50000}.txt", false)
    #    }.to perform_allocation(402000)
    #  end
end