require 'benchmark'
puts "#{RUBY_ENGINE rescue ''} #{RUBY_ENGINE == 'jruby' ? JRUBY_VERSION : RUBY_VERSION}"

def a
  "abc" * 100;
end

def b
  "def" * 100;
end

n = 1000000
Benchmark.bm(12) do |x|
  x.report('"#{a}#{b}"') { n.times { "#{a}#{b}" } }
  x.report('"" + a + b') { n.times { "" + a + b } }
  x.report('"" << a << b') { n.times { "" << a << b } }
end
