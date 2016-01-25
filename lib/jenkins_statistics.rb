require 'json'
require 'net/http'
require './lib/data_fetcher'
require './lib/dashboard_updater'

require './lib/reports/ci_report_base'
require './lib/reports/ci_passing_rate_report'
require './lib/reports/ci_flaky_tests_report'
require './lib/reports/ci_slowest_tests_report'
require './lib/reports/ci_time_broken_report'
require './lib/reports/ci_broken_by_report'



class JenkinsStatistics

  REPORTS =
  [
    {
      projects_names: ENV.fetch('TIME_BROKEN_REPORT_PROJECTS'),
      class_name: CITimeBrokenReport,
    },
    {
      projects_names: ENV.fetch('PASSING_RATE_REPORT_PROJECTS'),
      class_name: CIPassingRateReport,
    },
    {
      projects_names: ENV.fetch('SLOWEST_TESTS_REPORT_PROJECTS'),
      class_name: CISlowestTestsReport,
    },
    {
      projects_names: ENV.fetch('FLAKY_TESTS_REPORT_PROJECTS'),
      class_name: CIFlakyTestsReport,
    },
    {
      projects_names: ENV.fetch('BROKEN_BY_REPORT_PROJECTS'),
      class_name: CiBrokenByReport,
    },
  ]

  def self.generate
    # TODO: remove duplication and find a way of accessing ci only one per project

    REPORTS.each do |report|
      report[:projects_names].split(',').each do |project_name|
        report_generator = report[:class_name].new(project_name)
        report_generator.present
      end
    end
  end
end
