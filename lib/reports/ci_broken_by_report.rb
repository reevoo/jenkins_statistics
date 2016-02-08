class CiBrokenByReport < CIReportBase

  def present
    puts project + ' - ' + passing.to_s

    if !passing
      change_set = data_fetcher_instance.get_build(breaking_build)['changeSet']['items'][0]
      return if change_set.nil?

      DashboardUpdater.new(
        "#{project}-ci-status",
        'title' => project,
        'value' => passing ? 'passing' : 'failing',
        'text' => 'ss',
        'moreinfo' => change_set['author']['fullName'],
      ).update

      puts '-----------'
      puts "commitId = #{change_set['commitId']}"
      puts "name = #{change_set['author']['fullName']}"
      puts "commit message = #{change_set['msg']}"
      puts "date = #{change_set['date']}"
    end
  end

  def overall_data
    data_fetcher_instance.overall_data
  end

  def passing
    return true if overall_data['lastUnsuccessfulBuild'].nil?
    overall_data['lastSuccessfulBuild']['number'].to_i > overall_data['lastUnsuccessfulBuild']['number'].to_i
  end

  def breaking_build
    overall_data['lastStableBuild']['number'].to_i + 1
  end
end
