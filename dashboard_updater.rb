require 'json'
require 'net/http'

class DataFetcher
  attr_accessor :project

  def initialize(project)
    @project = project
  end

  def all_data
    @_build_data ||= build_data
  end

  def all_builds
    @_all_builds ||= DataFetcher.http_get(base_url)['builds']
  end

  def all_builds_detailed
    @_all_builds_detailed ||= get_builds_detailed
  end

  def self.http_get(url)
    JSON.parse(Net::HTTP.get(URI(url)))
  rescue JSON::ParserError
    nil
  end

  private

  def build_data
    build_data = []
    all_builds.each do |build|
      build_data << DataFetcher.http_get("#{build['url']}api/json")
    end
    build_data
  end

  def get_builds_detailed
    builds_detailed = all_data.dup
    builds_detailed.map do |build|
      build[:detailed_output] = DataFetcher.http_get(build['url'] + 'artifact/rspec.json')
    end
    builds_detailed
  end

  def base_url
    "http://ci-url.com/job/#{project}/api/json"
  end
end

class DashboardUpdater

  attr_reader :dashboard_id, :data

  def initialize(dashboard_id, data)
    @dashboard_id = dashboard_id
    @data = data
  end

  def update
    uri = URI("http://0.0.0.0:3030/widgets/#{dashboard_id}")
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
    req.body = { "auth_token" => "TOKEN_1"}.merge(data).to_json
    http.request(req)
  end
end

class CIReport
  attr_accessor :builds
  attr_reader :project

  def initialize(project, builds)
    @project = project
    @builds = builds
  end

  def present
  end
end

class CITimeBrokenReport < CIReport

  attr_accessor :time_broken_for, :time_passed_for, :previous_build

  def present
    generate

    DashboardUpdater.new(
      "#{project}-time-green-red",
      {"title" => "Green/Red time", "text" => "green:#{formated_time(time_passed_for)} red:#{formated_time(time_broken_for)}"}
    ).update
  end

  private

  def builds_data
    @_build_data ||= builds_timestamps    
  end

  def builds_timestamps
    builds_timestamps = []
    builds.each do |build|
      builds_timestamps << {
        time: build['timestamp'].to_i/1000,
        result: build['result']
      }
    end
    builds_timestamps.sort_by{ |b| b[:time]}
  end

  def generate
    self.time_broken_for = 0
    self.time_passed_for = 0

    builds_timestamps.each_with_index do |build, index|

      if self.previous_build
        if self.previous_build[:result] == 'SUCCESS' && build[:result] == 'SUCCESS'
          self.time_passed_for += (build[:time] - self.previous_build[:time])
        end
        if self.previous_build[:result] == 'FAILURE' && build[:result] == 'FAILURE'
          self.time_broken_for += (build[:time] - self.previous_build[:time])
        end
      end
      self.previous_build = build
    end
  end

  def formated_time(t)
    mm = t.divmod(60)
    hh, mm = mm.divmod(60)
    dd, hh = hh.divmod(24)
    "%dd,%dh,%dm "% [dd, hh, mm]
  end
end


class CIAverageDurrationReport < CIReport

  def present
    pass_rate = (success_builds.count*100/success_or_failure_builds.count)

    DashboardUpdater.new(
      "#{project}-passing-rate",
      {"value" => pass_rate, "title" => "Passing rate", "moreinfo" => "Success builds: #{success_builds.count} / Failed builds: #{failed_builds.count}"}
    ).update

    DashboardUpdater.new(
      "#{project}-overall-info",
      { 
        "text" => "#{builds.count} builds analysed", 
        "moreinfo" => "Average duration for succesfull builds: #{Time.at(avg_duration).utc.strftime("%H:%M:%S")}"
      }
    ).update
  end

  def success_or_failure_builds
    @_success_or_failure_builds ||= success_builds + failed_builds
  end

  def avg_duration
    return 0 if success_builds.empty?
    success_builds.map{|b| (b['duration'].to_f/1000)}.reduce(:+) / success_builds.count
  end

  def success_builds
    builds.select{|b| b['result'] == "SUCCESS"}
  end

  def failed_builds
    builds.select{|b| b['result'] == "FAILURE"}
  end
end

class CISlowestTestsReport < CIReport

  def present
    times = {}
    rounds = 0
    rounds_successful = 0

    builds.each do |build|
      rounds += 1
      next unless build['result'] == 'SUCCESS'
      next unless build[:detailed_output]
      rounds_successful += 1

      profile_examples = (build[:detailed_output]['profile'] && build[:detailed_output]['profile']['examples']) || []
      examples = build[:detailed_output]['examples'].concat(profile_examples)
      examples.each do |example|
        key = "#{example['file_path']}:#{example['line_number']}"
        times[key] ||= []
        times[key] << { run_time: example['run_time'], status: example['status'] }
      end
    end

    tests = CISlowestTestsReport.calc_avg_time(times).first(18)
      
    output = CISlowestTestsReport.format_output(tests)

    DashboardUpdater.new("slow-tests-#{project}", {"items" => output}).update
  end

  def self.calc_avg_time(times)
    stats = {}
    times.each do |key, value|
      if value.size > 2
        passing_builds = value.select{|x| x[:status] == 'passed'}.map{|x| x[:run_time]}.sort[1...-1]
        stats[key] = passing_builds.inject(0) { |sum, time| sum += time; sum } / (value.size - 2) if passing_builds
      end
    end
    stats.sort { |(_, time1), (_, time2)| time2 <=> time1 }
  end

  def self.format_output(times)
    times.each_with_object([]) do |(key, value), items|
      items << { label: key, value: '%.2f' % value }
    end
  end
end

class CIFlakyTestsReport < CIReport

  def present
    times = {}
    rounds = 0
    rounds_successful = 0
    builds.each do |build|
      rounds += 1
      next if build['result'] == 'SUCCESS' || !build[:detailed_output]
      rounds_successful += 1
      examples = build[:detailed_output]['examples'].concat((build[:detailed_output]['profile'] && build[:detailed_output]['profile']['examples']) || [])
      examples.each do |example|
        key = "#{example['file_path']}:#{example['line_number']}"
        times[key] ||= 1
        times[key] +=1
      end
    end
    times

    times = CIFlakyTestsReport.calc_nr_of_failure(times).last(18).reverse

    output = CIFlakyTestsReport.failures_format_output(times)
    puts output

    DashboardUpdater.new("flaky-tests-#{project}", {"items" => output}).update
  end
  
  def self.calc_nr_of_failure(times)
    times.sort_by { |key, val| val.to_i }
  end

  def self.failures_format_output(times)
    times.each_with_object([]) do |(key, value), items|
      items << { label: key, value: value }
    end
  end
end

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
