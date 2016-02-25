class CiBrokenByReport < CIReportBase

  def present
    # skip if breaking build cannot be found
    DashboardUpdater.new(
      "#{project}-ci-status",
      'title' => project,
      'status' => status_message,
    ).update
  end

  private

  def status_message
    if !passing
      "Broken by: #{change_set['author']['fullName']}"
    else
      'Passing'
    end
  end

  def change_set
    breaking_build['changeSet']['items'][0]
  end

  def build_overall_data
    data_fetcher_instance.overall_data
  end

  def passing
    # assume that is passing if lastUnsuccessfulBuild does not exist
    return true if build_overall_data.nil? || build_overall_data['lastUnsuccessfulBuild'].nil?
    build_overall_data['lastSuccessfulBuild']['number'].to_i >
      build_overall_data['lastUnsuccessfulBuild']['number'].to_i
  end

  def breaking_build_number
    return unless build_overall_data
    build_overall_data['lastStableBuild']['number'].to_i + 1
  end

  def breaking_build
    return unless breaking_build_number
    data_fetcher_instance.get_build(breaking_build_number)
  end
end
