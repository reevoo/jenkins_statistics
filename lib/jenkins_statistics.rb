require 'json'
require 'net/http'
require './lib/dotenv_init'
require './lib/data_fetcher'
require './lib/dashboard_updater'

require './lib/reports/ci_report_base'
require './lib/reports/ci_average_durration_report'
require './lib/reports/ci_flaky_tests_report'
require './lib/reports/ci_slowest_tests_report'
require './lib/reports/ci_time_broken_report'

class JenkinsStatistics
  
  def self.generate
    ENV.fetch('BRIEF_REPORT_FOR').split(',').each do |project|
      all_builds = DataFetcher.new(project).all_data.first(100)

      report = CITimeBrokenReport.new(project, all_builds.dup)
      report.present

      report = CIAverageDurrationReport.new(project, all_builds.dup)
      report.present
    end

    ENV.fetch('DETAILED_REPORT_FOR').split(',').each do |project|
      all_builds = DataFetcher.new(project).all_builds_detailed.first(100)

      report = CISlowestTestsReport.new(project, all_builds.dup)
      report.present

      report = CIFlakyTestsReport.new(project, all_builds.dup)
      report.present
    end
  end
end
