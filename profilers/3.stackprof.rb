require 'stackprof'
require_relative '../task/optimization'

puts 'Start'

StackProf.run(mode: :object, out: 'reports/stackprof.dump', raw: true) do
  work
end

puts 'Finish'
