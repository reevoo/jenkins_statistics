class CiBrokenByReport < CIReportBase

  def present
    if !passing
      change_set = data_fetcher_instance.get_build(breaking_build)['changeSet']['items'][0]
      return if change_set.nil?
      status = "Broken by: #{change_set['author']['fullName']}"
    else
      status = 'Passing'
    end
    DashboardUpdater.new(
      "#{project}-ci-status",
      'title' => project,
      'status' => status
    ).update
  end

  def overall_data
    data_fetcher_instance.overall_data
  end

  def passing
    return true if overall_data.nil? || overall_data['lastUnsuccessfulBuild'].nil?
    overall_data['lastSuccessfulBuild']['number'].to_i > overall_data['lastUnsuccessfulBuild']['number'].to_i
  end

  def breaking_build
    overall_data['lastStableBuild']['number'].to_i + 1
  end
end
