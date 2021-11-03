RSpec.describe GenerateReport do
  before { File.write('result.json', '') }

  it 'memory allocation less than 70MB' do
    expect { subject.work('spec/support/fixtures/data_large.txt') }.to perform_allocation(73_400_320).bytes
  end
end
