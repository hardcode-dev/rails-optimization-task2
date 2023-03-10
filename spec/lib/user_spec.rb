require 'spec_helper'

describe '.work' do
  it 'write correct result to file' do
    expected_result = JSON.parse(File.read("./spec/fixtures/result.json"))

    work(input_path: "./spec/fixtures/data.txt", output_path: "./tmp/result.json")

    result = JSON.parse(File.read("./tmp/result.json"))

    expect(result).to eq(expected_result)
  end
end