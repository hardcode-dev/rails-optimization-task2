require 'stackprof'
require 'json'

require_relative '../task-2.rb'

## flamegraph
# StackProf.run(mode: :object, raw: true, out: 'stackprof_reports/stackprof_obj.dump') do
#   work('./benchmark/support/data_16k.txt', disable_gc: true)
# end

# stackprof --flamegraph stackprof_reports/stackprof_obj.dump > stackprof_reports/flamegraph
# stackprof --flamegraph-viewer=stackprof_reports/flamegraph

## https://www.speedscope.app/
profile = StackProf.run(mode: :object, raw: true) do
  work('./benchmark/support/data_16k.txt', disable_gc: true)
end

File.write('stackprof_reports/stackprof.json', JSON.generate(profile))
