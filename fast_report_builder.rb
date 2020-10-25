class FastReportBuilder
  def call(source_filename, report_filename)
    puts "~ 🚅 Fast Report Builder ~"

    # Build report without loading whole file to memory.
    build_report(source_filename, report_filename)

    puts "~ 🏁 Finished. MEMORY USAGE: #{memory_usage_mb} MB ~"
  end

  private

  def build_report(source_filename, report_filename)

  end

  def memory_usage_mb
    `ps -o rss= -p #{Process.pid}`.to_i / 1024
  end
end