require 'spec_helper'

require 'data_fetcher'


describe DataFetcher do
  describe '.http_get' do
    let(:url){ URI('http//example.com') }
    it 'calls get on Net::HTTP with the right attr and parses the response' do
      json_example = '{"report_1": "data_1"}'
      expect(Net::HTTP).to receive(:get).with(url).and_return(json_example)
      response_data = DataFetcher.http_get('http//example.com')

      expect(response_data).to eq("report_1" => "data_1")
    end

    it 'returns nil if the response cannot be parsed' do      
      expect(Net::HTTP).to receive(:get).and_raise(JSON::ParserError)
      response_data = DataFetcher.http_get('http//example.com')

      expect(response_data).to eq(nil)
    end
  end


  describe '#all_builds' do
    let(:response_data) do 
      { 'builds' => [{'build_1' => 'data_1'}] }
    end
    it 'returns an array of builds' do
      allow(DataFetcher).to receive(:http_get).and_return(response_data)

      builds = DataFetcher.new('project_1').all_builds
      expect(builds).to eq(response_data['builds'])
    end
  end
end