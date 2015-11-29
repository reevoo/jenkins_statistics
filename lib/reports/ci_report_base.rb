class CIReportBase
  attr_accessor :builds
  attr_reader :project

  def initialize(project, builds)
    @project = project
    @builds = builds
  end

  def present
  end
end