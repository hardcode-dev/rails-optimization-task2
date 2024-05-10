require_relative '../task-2'

describe 'Memory' do
  context 'it works properly' do
    let(:sample100_result) { File.join(fixtures_path, 'sample100_result.json') }
    let(:real_result_file) { File.join(root_path, 'result.json') }
    let(:size) { 100 }

    ## script to prepare test data
    # it {
    #   prepare_data(size) do |filename|
    #     work(filename)

    #     File.open(sample100_result, 'w') { |file| file.write(File.read(real_result_file)) }
    #   end
    # }

    it {
      prepare_data(size) { |filename| work(filename) }

      expect(JSON.parse(File.read(real_result_file))).to eq(JSON.parse(File.read(sample100_result)))
    }
  end

  context 'works on 1_000 lines within 13 MB' do
    let(:size) { 1_000 }

    it {
      prepare_data(size) do |filename|
        expect {
          work(filename)
        }.to perform_allocation(13 * 1024 * 1024).bytes
      end
    }
  end
end
