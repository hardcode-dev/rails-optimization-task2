require 'rspec-benchmark'
require_relative '../task/optimization'

RSpec.describe "Performance testing" do
  include RSpec::Benchmark::Matchers

  describe 'Performance' do
    before do
      File.write('result.json', '')
      File.write('data.txt', count.times.flat_map do |step|
        [
          "user,#{step},Leida_#{step},Cira,0",
          "session,#{step},#{step},Safari 29,87,2016-10-23",
          "session,#{step},#{step},Safari 29,87,2016-10-23",
          "session,#{step},#{step},Safari 29,87,2016-10-23",
          "session,#{step},#{step},Safari 29,87,2016-10-23"
        ]
      end.join("\n"))
    end

    subject do
      work

      `ps -o rss= -p #{Process.pid}`.to_i / 1024
    end

    context 'with 25500 rows (~ 1Mb)' do
      let(:count) { 5100 }

      it { is_expected.to eq(32) }
    end

    context 'with 255000 rows (~ 10Mb)' do
      let(:count) { 5100 }

      it { is_expected.to eq(35) }
    end

    context 'with 2550000 rows (~ 100Mb)' do
      let(:count) { 51000 }

      it { is_expected.to eq(66) }
    end
  end
end
