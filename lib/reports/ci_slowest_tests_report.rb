class CISlowestTestsReport < CIReportBase

  def present # rubocop:disable Metrics/AbcSize
    times = {}
    rounds = 0
    rounds_successful = 0

    all_builds_detailed.each do |build|
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

    DashboardUpdater.new("slow-tests-#{project}", 'items' => output).update
  end

  def self.calc_avg_time(times) # rubocop:disable Metrics/AbcSize
    stats = {}
    times.each do |key, value|
      if value.size > 2
        passing_builds = value.select { |x| x[:status] == 'passed' }.map { |x| x[:run_time] }.sort[1...-1]
        stats[key] = passing_builds.inject(:+) / (value.size - 2) if passing_builds
      end
    end
    stats.sort { |(_, time1), (_, time2)| time2 <=> time1 }
  end

  def self.format_output(times)
    times.each_with_object([]) do |(key, value), items|
      items << { label: key, value: sprintf('%.2f', value) }
    end
  end
end
