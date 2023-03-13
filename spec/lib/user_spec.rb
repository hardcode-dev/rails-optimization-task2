require 'spec_helper'

describe '.work' do
  it 'write correct result to file' do
    expected_result = JSON.parse(File.read("./spec/fixtures/result.json"))

    work(input_path: "./spec/fixtures/data.txt", output_path: "./tmp/result.json")

    result = JSON.parse(File.read("./tmp/result.json"))

    expect(result).to eq(expected_result)
  end

  it 'perform time less than 0.0003 sec' do
    expect { 
      work(input_path: "./spec/fixtures/data.txt", output_path: "./tmp/result.json")
    }.to perform_under(0.003).sample(10)
  end

  it "perform linear" do
    expect { |n, i|
      file_name =  n / 1000
      work(input_path: "./spec/fixtures/data-#{file_name}k.txt", output_path: "./tmp/result.json")
    }.to perform_linear.in_range(1_000, 10_000).sample(25).ratio(2)
  end
end