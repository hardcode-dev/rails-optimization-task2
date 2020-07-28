require_relative '../spec_helper'
require_relative '../../task-2'

RSpec.describe 'Report' do
  it 'performs valid report data' do
    work('data_files/regress_data.txt')

    expected_json = JSON.parse(File.read('data_files/regress_expected_data.json'))
    result_json = JSON.parse(File.read('data_files/result.json'))

    expect(expected_json).to eq(result_json)
  end

  it 'uses less than 32 mb' do
      prepare_sample_for_speed_test(200_000)

      mem_use = work('data_files/data200000.txt', false)
      expect(mem_use).to be <= 32.0
    end

  # it 'big data works under 30 000 ms' do
  #   expect {
  #     work('data_files/data_large.txt')
  #   }.to perform_under(16_000).ms
  # end
end
