class CiBrokenByReport < CIReportBase

  def present
    puts project + ' - ' + passing.to_s

    if !passing
      change_set = data_fetcher_instance.get_build(breaking_build)['changeSet']['items'][0]
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
    overall_data['lastSuccessfulBuild']['number'].to_i > overall_data['lastUnsuccessfulBuild']['number'].to_i
  end

  def breaking_build
    overall_data['lastStableBuild']['number'].to_i + 1
  end
end
