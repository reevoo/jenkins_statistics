class CIReportBase
  attr_reader :project

  def initialize(project)
    @project = project
  end

  def present
  end

  def data_fetcher_instance
    DataFetcher.new(project)
  end

  def all_builds
    @all_builds ||= data_fetcher_instance.all_data.first(ENV.fetch('NUMBER_OF_BUILDS_TO_ANALYSE').to_i)
  end

  def all_builds_detailed
    @all_builds_detailed ||= data_fetcher_instance
                             .all_builds_detailed
                             .first(ENV.fetch('NUMBER_OF_BUILDS_TO_ANALYSE').to_i)
  end
end
