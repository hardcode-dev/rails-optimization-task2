# frozen_string_literal: true

require 'tabulo'
require_relative 'stand'

module PerfAnalyzer
  # Осуществляет запуск профилировщиков и бенчмарков в цикле с предоставлением обратной связи и
  # упрощением выполнения рутинных операций
  class Loop
    attr_reader :stand, :results_file_name, :study_file_name, :new_results

    def initialize(stand, reports_dir: 'reports')
      @stand = stand
      @results_file_name = "#{reports_dir}/last_analyze_results.yaml"
      @study_file_name = "#{reports_dir}/study.md"
      @new_results = {}
    end

    def analyze(...)
      new_results.merge!(stand.analyze(...))
      self
    end

    def benchmark(...)
      new_results['benchmark'] = stand.benchmark(...)
      self
    end

    def check_results
      puts diff_results
      return unless we_happy?

      save_results
      show_editor
    end

    private

    def diff_results
      tools = old_results.keys | new_results.keys
      diff = +''
      tools.each do |tool|
        tool_old_results = old_results[tool] || {}
        tool_new_results = new_results[tool] || {}
        diff << render_diff_table(tool, tool_old_results, tool_new_results)
        diff << "\n"
      end
      diff
    end

    def old_results
      @old_results ||=
        if File.exist?(results_file_name)
          YAML.safe_load(File.read(results_file_name))
        else
          {}
        end
    end

    def render_diff_table(tool, tool_old_results, tool_new_results)
      rows =
        (tool_old_results.keys | tool_new_results.keys).map do |property|
          [property, tool_old_results[property], tool_new_results[property]]
        end
      Tabulo::Table.new(rows, border: :markdown) do |t|
        t.add_column(tool.to_s, width: 30) { |row| row[0] }
        t.add_column('Было', width: 15) { |row| row[1] }
        t.add_column('Стало', width: 15) { |row| row[2] }
        t.add_column('Разница', width: 15) do |row|
          (row[2].to_i - row[1].to_i) if row[1] && row[2]
        end
        t.add_column('Разница %', width: 15) do |row|
          "#{(row[2].to_i - row[1].to_i) * 100 / row[1].to_i}%" if row[1] && row[2]
        end
      end.to_s
    end

    def we_happy?
      puts 'Vincent, we happy? [(y)eah! we happy / (N)ay]'
      gets.chomp == 'y'
    end

    def show_editor
      report = edit_tempfile

      if empty_report?(report)
        puts 'отчёт не сохранён'
        return
      end

      append_stages(report)
    end

    def save_results
      File.write(results_file_name, new_results.to_yaml)
    end

    def edit_tempfile
      tempfile = Tempfile.open('perf_analyze_stage')
      tempfile.write("\n\n")
      tempfile.write(diff_results.split("\n").map { |l| "// #{l}" }.join("\n"))
      tempfile.close

      system("#{ENV.fetch('EDITOR', 'vim')} #{tempfile.path}")
      report = read_report(tempfile)
    ensure
      tempfile.unlink
      report
    end

    def read_report(tempfile)
      File.read(tempfile.path)
          .split("\n")
          .reject { |l| l.start_with?('//') }
          .join("\n")
    end

    def empty_report?(report)
      report.chomp.empty?
    end

    def append_stages(report)
      File.open(study_file_name, 'a') do |f|
        f.write("\n")
        f.write(report)
        f.write("\n")
        f.write(diff_results)
      end
    end
  end
end
