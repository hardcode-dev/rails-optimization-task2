RSpec.describe 'Ram' do
  subject { work(file_path) }

  let(:size) { 10_000 }
  let(:file_path) { fixture(size) }

  before { ensure_test_data_exists(size) }

  it 'does not eat all ram' do
    subject
  end
end
