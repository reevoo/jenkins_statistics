require 'job'
require 'actions/build'


class UpdateStatsDb < Job

  def run(projects: [])
    projects.each { |prj| process_project(prj) }
  end

  def process_project(name, builds_range = nil)
    project = StatsDb::Project.find_or_create(name: name.to_s)
    fetcher = DataFetcher.new(project.name)
    if builds_range
      builds_range.to_a.each do |id|
        doc = fetcher.get_build(id)
        process_build(project, doc)
      end
    else
      fetcher.each_build { |doc| process_build(project, doc) }
    end
  end

  private

  def process_build(project, build_json)
    return if build_json.blank?
    return unless project.builds_dataset.where(ci_id: build_json['id'].to_i).empty?
    print '.'

    Build::Process.new(
      build_json: build_json,
      rspec_json: DataFetcher.retrieve_rspec_json(build_json),
      project: project,
      upstream_strategy: :fetch,
    ).execute
  end
end
