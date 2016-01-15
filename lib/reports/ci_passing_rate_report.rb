class CIPassingRateReport < CIReportBase

  def present
    update_passing_rate
    update_overall_info
  end

  private

  def update_passing_rate
    DashboardUpdater.new(
      "#{project}-passing-rate",

      'value' => pass_rate,
      'title' => 'Passing rate',
      'moreinfo' => "Success builds: #{success_builds.count} / Failed builds: #{failed_builds.count}",

    ).update
  end

  def update_overall_info
    DashboardUpdater.new(
      "#{project}-overall-info",

      'text' => "#{all_builds.count} builds analysed",
      'moreinfo' => "Average duration for succesfull builds: #{Time.at(avg_duration).utc.strftime('%H:%M:%S')}",

    ).update
  end

  def pass_rate
    success_builds.count * 100 / success_or_failure_builds.count
  end

  def success_or_failure_builds
    @_success_or_failure_builds ||= success_builds + failed_builds
  end

  def avg_duration
    return 0 if success_builds.empty?
    success_builds.map { |b| (b['duration'].to_f / 1000) }.reduce(:+) / success_builds.count
  end

  def success_builds
    all_builds.select { |b| b['result'] == 'SUCCESS' }
  end

  def failed_builds
    all_builds.select { |b| b['result'] == 'FAILURE' }
  end
end
