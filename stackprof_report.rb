require 'stackprof'
require_relative 'task-2'

StackProf.run(mode: :object, out: 'stackprof_reports/stackprof.dump', raw: true) do
  work(file_name: ENV['FILE_NAME'], gc_disabled: true)
end