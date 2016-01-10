class CIFlakyTestsReport < CIReportBase

  def present
    times = {}
    rounds = 0
    rounds_successful = 0
    all_builds_detailed.each do |build|
      rounds += 1
      next unless build['result'] == 'SUCCESS'
      next unless build[:detailed_output]
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
