require 'spec_helper'
require 'reports/ci_broken_by_report'

describe CiBrokenByReport do
  describe '.present' do
    let(:project) { 'project_1' }


    context 'when passing' do
      it 'updates the dashboard' do
        allow_any_instance_of(DashboardUpdater).to receive(:update)
        allow_any_instance_of(DataFetcher)
          .to receive(:overall_data).and_return(

              'lastSuccessfulBuild' => { 'number' => 2 },
              'lastUnsuccessfulBuild' => { 'number' => 1 },
              'lastStableBuild' => { 'number' => 2 },

          )

        expect(DashboardUpdater)
          .to receive(:new).with(
            'project_1-ci-status',

            'title' => 'project_1',
            'status' => 'Passing',

          ).and_call_original

        report = CiBrokenByReport.new(project)
        report.present
      end
    end
    context 'when broken' do
      it 'updates the dashboard with the broken_by name' do
        allow_any_instance_of(DashboardUpdater).to receive(:update)
        allow_any_instance_of(DataFetcher)
          .to receive(:get_build).and_return(

              'changeSet' =>
                {
                  'items' =>
                    [
                      { 'author' => { 'fullName' => 'Name 1' } },
                    ],
                },

          )

        allow_any_instance_of(DataFetcher)
          .to receive(:overall_data).and_return(

              'lastSuccessfulBuild' => { 'number' => 2 },
              'lastUnsuccessfulBuild' => { 'number' => 4 },
              'lastStableBuild' => { 'number' => 2 },

          )

        expect(DashboardUpdater)
          .to receive(:new).with(
            'project_1-ci-status',

            'title' => 'project_1',
            'status' => 'Broken by: Name 1',

          ).and_call_original

        report = CiBrokenByReport.new(project)
        report.present
      end
    end
  end
end
