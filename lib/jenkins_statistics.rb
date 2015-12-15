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
    # TODO remove duplication and find a way of accessing ci only one per project

    ENV.fetch('TIME_BROKEN_REPORT_PROJECTS').split(',').each do |project|
      all_builds = DataFetcher.new(project).all_data.first(ENV.fetch('NUMBER_OF_BUILDS_TO_ANALIZE').to_i)
      report = CITimeBrokenReport.new(project, all_builds.dup)
      report.present
    end

    ENV.fetch('AVERAGE_DURRATION_REPORT_PROJECTS').split(',').each do |project|
      all_builds = DataFetcher.new(project).all_data.first(ENV.fetch('NUMBER_OF_BUILDS_TO_ANALIZE').to_i)
      report = CIAverageDurrationReport.new(project, all_builds.dup)
      report.present
    end

    ENV.fetch('SLOWEST_TESTS_REPORT_PROJECTS').split(',').each do |project|
      all_builds_detailed = DataFetcher.new(project).all_builds_detailed.first(ENV.fetch('NUMBER_OF_BUILDS_TO_ANALIZE').to_i)
      report = CISlowestTestsReport.new(project, all_builds_detailed.dup)
      report.present
    end

    ENV.fetch('FLAKY_TESTS_REPORT_PROJECTS').split(',').each do |project|
      all_builds_detailed = DataFetcher.new(project).all_builds_detailed.first(ENV.fetch('NUMBER_OF_BUILDS_TO_ANALIZE').to_i)
      report = CIFlakyTestsReport.new(project, all_builds_detailed.dup)
      report.present
    end
  end
end
