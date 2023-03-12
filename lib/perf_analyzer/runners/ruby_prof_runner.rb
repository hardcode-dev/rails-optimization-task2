# frozen_string_literal: true

require 'ruby-prof'
require_relative 'base'

module PerfAnalyzer
  module Runners
    # :nodoc:
    class RubyProfRunner < Base
      def run(**options, &block)
        result = RubyProf::Profile.profile(**options, &block)
        report_flat(result)
        report_dot(result)
        report_graph(result)
        report_callstack(result)
        {}
      end

      def report_flat(result)
        File.open("#{@report_dir}/ruby-prof-flat.txt", 'w') do |f|
          RubyProf::FlatPrinter.new(result).print(f)
        end
      end

      def report_dot(result)
        File.open("#{@report_dir}/ruby-prof-graphviz.dot", 'w') do |f|
          RubyProf::DotPrinter.new(result).print(f)
        end
      end

      def report_graph(result)
        File.open("#{@report_dir}/ruby-prof-graph.html", 'w') do |f|
          RubyProf::GraphHtmlPrinter.new(result).print(f, sort_method: :self_time)
        end
      end

      def report_callstack(result)
        File.open("#{@report_dir}/ruby-prof-callstack.html", 'w') do |f|
          RubyProf::CallStackPrinter.new(result).print(f)
        end
      end
    end
  end
end
