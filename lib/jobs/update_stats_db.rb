require 'job'
require 'date'


class UpdateStatsDb < Job

  def run(projects: [])
    projects.each { |prj| process_project(prj) }
  end

  private

  def process_project(name)
    project = StatsDb::Project.find_or_create(name: name.to_s)
    fetcher = DataFetcher.new(project.name)
    fetcher.each_build { |doc| process_build(project, doc) }
  end

  def process_build(project, build_json)
    print '.'
    return unless project.builds_dataset.where(id: build_json['id'].to_i).empty?
    rspec_json = DataFetcher.retrieve_rspec_json(build_json)
    build = project.add_build(build_record_attributes(build_json, rspec_json))
    process_rspec_json(project, build, rspec_json)
  end

  def build_record_attributes(build_json, rspec_json)
    {
      id: build_json['id'].to_i,
      result: build_json['result'].downcase,
      document: build_json,
      rspec_json: rspec_json,
      timestamp: DateTime.strptime((build_json['timestamp'] / 1000).to_s, '%s'),
    }
  end

  def process_rspec_json(project, build, rspec_json)
    return if rspec_json.blank?
    rspec_json['examples'].each do |example|
      spec = StatsDb::Spec.find_or_create(project: project, file_path: example['file_path'])
      spec_case = StatsDb::SpecCase.find_or_create(spec: spec, description: example['full_description'])

      spec_case.add_spec_case_run(
        build: build,
        status: example['status'],
        exception: example['exception'],
        run_time: example['run_time'],
      )
    end
  end
end
