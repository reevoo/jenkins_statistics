require 'spec_helper'
require 'dashboard_updater'

describe DashboardUpdater do
  let(:dashboard_id){ 'dashboard_1' }
  let(:json_example) do
    { value: 1 }
  end
  subject{ DashboardUpdater.new(dashboard_id, json_example) }

  describe '#update' do
    it 'posts the json data to the dashboard endpoint' do
      expect_any_instance_of(Net::HTTP)
        .to receive(:request).with(an_instance_of(Net::HTTP::Post))

      subject.update
    end
  end
end