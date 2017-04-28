require 'job'
require 'reports/ci_report_base'
require 'reports/ci_passing_rate_report'
require 'reports/ci_flaky_tests_report'
require 'reports/ci_slowest_tests_report'
require 'reports/ci_time_broken_report'
require 'reports/ci_broken_by_report'


class UpdateDashboard < Job

  def init(env) # rubocop:disable TrivialAccessors
    @env = env
  end

  def reports
    [
      {
        projects_names: @env.fetch('TIME_BROKEN_REPORT_PROJECTS'),
        class_name: CITimeBrokenReport,
      },
      {
        projects_names: @env.fetch('PASSING_RATE_REPORT_PROJECTS'),
        class_name: CIPassingRateReport,
      },
      {
        projects_names: @env.fetch('SLOWEST_TESTS_REPORT_PROJECTS'),
        class_name: CISlowestTestsReport,
      },
      {
        projects_names: @env.fetch('FLAKY_TESTS_REPORT_PROJECTS'),
        class_name: CIFlakyTestsReport,
      },
      {
        projects_names: @env.fetch('BROKEN_BY_REPORT_PROJECTS'),
        class_name: CiBrokenByReport,
      },
    ]
  end

  def run(*)
    # TODO: remove duplication and find a way of accessing ci only one per project

    reports.each do |report|
      report[:projects_names].split(',').each do |project_name|
        report_generator = report[:class_name].new(project_name)
        report_generator.present
      end
    end
  end
end
