# frozen_string_literal: true

require 'tempfile'

RSpec.describe '#work' do
  it 'produces valid result for known input' do
    expected_result = JSON.parse(File.read('spec/fixtures/result.json'))

    Tempfile.create do |result|
      work(src: 'spec/fixtures/data.txt', dest: result.path)

      actual_result = JSON.parse(File.read(result.path))

      expect(actual_result).to eq(expected_result)
    end
  end
end
