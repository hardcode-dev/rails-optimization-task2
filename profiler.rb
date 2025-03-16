require 'memory_profiler'
require 'stackprof'
require 'ruby-prof'

require_relative 'main'

class Profiler
  def initialize(count_lines:)
    @count_lines = count_lines
  end

  def call
    profile_by_memory_profiler
    profile_memory_by_ruby_prof
    profile_allocations_by_ruby_prof
    profile_allocations_by_stack_prof
  end

  private

  attr_reader :count_lines

  def profile_by_memory_profiler
    report = MemoryProfiler.report { action }
    report.pretty_print(to_file: './profiles/memory_profiler')
  end

  def profile_memory_by_ruby_prof
    RubyProf.measure_mode = RubyProf::MEMORY
    result = RubyProf.profile { action }
    printer = RubyProf::CallTreePrinter.new(result)
    printer.print(:path => ".", :profile => "profiles/ruby_prof_memory_profile")
  end

  def profile_allocations_by_ruby_prof
    RubyProf.measure_mode = RubyProf::ALLOCATIONS
    result = RubyProf.profile { action }
    printer = RubyProf::CallTreePrinter.new(result)
    printer.print(:path => ".", :profile => "profiles/ruby_prof_allocations_profile")
  end

  def profile_allocations_by_stack_prof
    StackProf.run(mode: :object, out: 'profiles/stackprof.dump') do
      action
    end
  end

  def action = Main.new(options: { count_lines: }).call
end
