require 'job'
require 'date'


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
        process_build(project, doc) if doc
      end
    else
      fetcher.each_build { |doc| process_build(project, doc) }
    end
  end

  private

  def process_build(project, build_json)
    return unless build_json
    build = project.builds_dataset.where(ci_id: build_json['id'].to_i).first
    return build if build
    rspec_json = DataFetcher.retrieve_rspec_json(build_json)
    print '.'
    build = project.add_build(build_record_attributes(build_json, rspec_json))
    process_rspec_json(project, build, rspec_json)
    build
  end

  def build_record_attributes(build_json, rspec_json)
    attributes = {
      ci_id: build_json['id'].to_i,
      result: build_json['result'].try(:downcase),
      document: build_json,
      rspec_json: rspec_json,
      timestamp: DateTime.strptime((build_json['timestamp'] / 1000).to_s, '%s'),
    }
    return attributes unless build_json['actions'].is_a?(Array)
    action = build_json['actions'].find { |action| action.key?('causes') }
    cause = action['causes'][0] if action
    return attributes unless cause && cause['upstreamProject'] && cause['upstreamBuild']

    upstream_project = StatsDb::Project.find_or_create(name: cause['upstreamProject'])
    fetcher = DataFetcher.new(cause['upstreamProject'])
    upstream_build = process_build(upstream_project, fetcher.get_build(cause['upstreamBuild']))

    attributes.merge(
      upstream_build_id: upstream_build.try(:id),
      upstream_project_id: upstream_project.try(:id),
    )
  end

  def process_rspec_json(project, build, rspec_json)
    return if rspec_json.blank?
    (rspec_json['examples'] || []).each do |example|
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
