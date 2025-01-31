#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative '../lib/profiler'

begin
  prof_type = ARGV[0]

  available_types = %w[
    memeory_prof
    stack_prof
    ruby_prof
  ]

raise StandardError, "unknow profiler type: #{prof_type}" unless available_types.include?(prof_type)

  Profiler.make_report(prof_type)
end