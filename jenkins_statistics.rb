require 'json'
require 'net/http'
require './data_fetcher'
require './data_fetcher'
require './dashboard_updater'

require './reports/ci_report_base'
require './reports/ci_average_durration_report'
require './reports/ci_flaky_tests_report'
require './reports/ci_slowest_tests_report'
require './reports/ci_time_broken_report'

class JenkinsStatistics
  
  def self.generate
    %w(project_1 project_2).each do |project|
      all_builds = DataFetcher.new(project).all_data.first(100)

      report = CITimeBrokenReport.new(project, all_builds.dup)
      report.present

      report = CIAverageDurrationReport.new(project, all_builds.dup)
      report.present
    end

    %w(project_3 project_4).each do |project|
      all_builds = DataFetcher.new(project).all_builds_detailed.first(100)

      report = CISlowestTestsReport.new(project, all_builds.dup)
      report.present

      report = CIFlakyTestsReport.new(project, all_builds.dup)
      report.present
    end
  end
end

JenkinsStatistics.generate