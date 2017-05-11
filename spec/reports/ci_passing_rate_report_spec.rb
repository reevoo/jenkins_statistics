require "spec_helper"
require "reports/ci_passing_rate_report"

describe CIPassingRateReport do
  describe "#present" do
    let(:project) { "project_1" }
    let(:duration_in_miliseconds) { 1_200_000 } # 1200000miliseconds = 20min
    let(:all_builds)do
      [
        { "result" => "SUCCESS", "duration" => duration_in_miliseconds },
        { "result" => "SUCCESS", "duration" => duration_in_miliseconds },
        { "result" => "FAILURE", "duration" => duration_in_miliseconds },
      ]
    end
    it "calls dashboard updater with the right parameters" do
      allow_any_instance_of(DashboardUpdater).to receive(:update)
      allow_any_instance_of(CIReportBase)
        .to receive(:all_builds).and_return(all_builds)

      expect(DashboardUpdater).to receive(:new)
        .once.ordered
        .with(
          "project_1-passing-rate",

          "value" => 66,
          "title" => "Passing rate",
          "moreinfo" => "Success builds: 2 / Failed builds: 1",

        ).and_call_original

      expect(DashboardUpdater).to receive(:new)
        .once.ordered
        .with(
          "project_1-overall-info",

          "text" => "3 builds analysed",
          "moreinfo" => "Average duration for succesfull builds: 00:20:00",

        ).and_call_original

      report = CIPassingRateReport.new(project)
      report.present
    end
  end
end
