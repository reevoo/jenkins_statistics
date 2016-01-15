require 'spec_helper'
require 'data_fetcher'

describe DataFetcher do
  describe '.http_get' do
    let(:url) { URI('http//example.com') }
    it 'calls get on Net::HTTP with the right attr and parses the response' do
      json_example = '{"report_1": "data_1"}'
      expect(Net::HTTP).to receive(:get).with(url).and_return(json_example)
      response_data = DataFetcher.http_get('http//example.com')

      expect(response_data).to eq('report_1' => 'data_1')
    end

    it 'returns nil if the response cannot be parsed' do
      expect(Net::HTTP).to receive(:get).and_raise(JSON::ParserError)
      response_data = DataFetcher.http_get('http//example.com')

      expect(response_data).to eq(nil)
    end
  end


  describe '#all_builds' do
    let(:response_data) do
      { 'builds' => [{ 'build_1' => 'data_1' }] }
    end
    it 'returns an array of builds' do
      allow(DataFetcher).to receive(:http_get).and_return(response_data)

      builds = DataFetcher.new('project_1').all_builds
      expect(builds).to eq(response_data['builds'])
    end
  end

  describe '#all_data' do
    let(:build_data_example) do
      { report_1: 'data_1' }
    end
    it 'returns an array of data about each build' do
      allow_any_instance_of(DataFetcher)
        .to receive(:all_builds).and_return([{ 'url' => 'http://example.com/build1/' }])

      allow(DataFetcher)
        .to receive(:http_get).with('http://example.com/build1/api/json')
        .and_return(build_data_example)

      all_data = DataFetcher.new('project_1').all_data
      expect(all_data).to eq([{ report_1: 'data_1' }])
    end
  end

  describe '#all_builds_detailed' do
    let(:detailed_build_data_json) do
      { spec1: { time_taken_to_run: 2 } }
    end
    let(:build_data_example) do
      { 'url' => 'http://example.com/build1/', 'build_1' => 'data_1' }
    end
    it 'returns an array of detailed data about each build' do
      allow_any_instance_of(DataFetcher)
        .to receive(:all_data).and_return([build_data_example])

      allow(DataFetcher)
        .to receive(:http_get).with('http://example.com/build1/artifact/rspec.json')
        .and_return(detailed_build_data_json)

      all_builds_detailed = DataFetcher.new('project_1').all_builds_detailed
      expect(all_builds_detailed).to eq(
        [
          {
            'url' => 'http://example.com/build1/',
            'build_1' => 'data_1',
            :detailed_output => detailed_build_data_json,
          },
        ],
      )
    end
  end
end
