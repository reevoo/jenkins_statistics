class CIReportBase
  attr_reader :project

  def initialize(project)
    @project = project    
  end

  def present    
  end

  def all_builds
    @all_builds ||= DataFetcher.new(project).all_data.first(ENV.fetch('NUMBER_OF_BUILDS_TO_ANALYSE').to_i)
  end

  def all_builds_detailed
    @all_builds_detailed ||= DataFetcher.new(project).all_builds_detailed.first(ENV.fetch('NUMBER_OF_BUILDS_TO_ANALYSE').to_i)
  end
end