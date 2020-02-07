# frozen_string_literal: true

require './report'


class Task
  attr_reader :file_path

  def initialize(file_path)
    @file_path = file_path
  end

  def generate_report
    report = Report.new

    IO.foreach(file_path) do |line|
      cols = line.split(',')
      if cols[0] == 'user'
        report.commit_user
        report.add_user cols
      else
        report.update_session_stat(cols[3])
        report.update_user_stat(cols)
      end
    end
    report.commit

    puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
  end
end
