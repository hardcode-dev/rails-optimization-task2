# frozen_string_literal: true

require 'rspec-benchmark'
require 'json_spec'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end
