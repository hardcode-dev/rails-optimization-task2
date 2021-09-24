# frozen_string_literal: true

require_relative '../task-2'

RSpec.describe 'Task №2' do
  describe '#work' do
    let(:size) { 18 }

    context 'health check' do
      let(:result_data) { File.read('spec/fixtures/result.json') }

      it 'returns users data(in json)' do
        work('spec/fixtures/data18.txt')
        expect(JSON.parse(File.read('result.json'))).to eq(JSON.parse(result_data))
      end
    end
  end
end

