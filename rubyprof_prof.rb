require_relative 'config/environment'

RubyProf.measure_mode = RubyProf::ALLOCATIONS

result = RubyProf.profile do
  GenerateReport.new.work('spec/support/fixtures/data_16000.txt')
end

File.open(
  "/home/artur/Thinknetica/optimization/lesson-02/rails-optimization-task2/profiler_reports/memory_flat.txt",
  'w+'
) do |file|
  RubyProf::FlatPrinter.new(result).print(file)
end

File.open(
  "/home/artur/Thinknetica/optimization/lesson-02/rails-optimization-task2/profiler_reports/memory_dot.txt",
  'w+'
) do |file|
  RubyProf::DotPrinter.new(result).print(file)
end

File.open(
  "/home/artur/Thinknetica/optimization/lesson-02/rails-optimization-task2/profiler_reports/memory_graph.html",
  'w+'
) do |file|
  RubyProf::GraphHtmlPrinter.new(result).print(file)
end

File.open(
  "/home/artur/Thinknetica/optimization/lesson-02/rails-optimization-task2/profiler_reports/memory_callstack.html",
  'w+'
) do |file|
  RubyProf::CallStackPrinter.new(result).print(file)
end
