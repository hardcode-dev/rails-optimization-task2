require_relative 'main'

class Measurer
  def call
    Main.new(options: { count_lines: 15_000, is_print_memory_usage: true }).call
  end
end

# Zero iteration:
# 15_000 lines: 103 MB
