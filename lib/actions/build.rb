require "date"

module Build
  class Process
    UPSTREAM_STRATEGIES = [:find, :fetch].freeze

    def initialize(build_json:, rspec_json: nil, project: nil, upstream_strategy: :find)
      @build_json = build_json
      @rspec_json = rspec_json
      @project = project || get_project_from_build_json(build_json)
      @upstream_strategy = (UPSTREAM_STRATEGIES & [upstream_strategy]).first
    end

    def execute
      @project.add_build(build_record_attributes(@build_json, @rspec_json)).tap do |build|
        process_rspec_json(build, @rspec_json)
      end
    end

    private

    def get_project_from_build_json(json)
      fail "Build json does not contain url" unless json["url"] =~ %r{/job/([^/]+)}
      StatsDb::Project.where(name: Regexp.last_match[1]).first
    end

    def build_record_attributes(build_json, rspec_json) # rubocop:disable Metrics/AbcSize
      attributes = {
        ci_id: build_json["id"].to_i,
        result: build_json["result"].try(:downcase),
        document: build_json,
        rspec_json: rspec_json,
        timestamp: DateTime.strptime((build_json["timestamp"] / 1000).to_s, "%s"),
      }
      return attributes unless build_json["actions"].is_a?(Array)
      action = build_json["actions"].find { |a| a.key?("causes") }
      cause = action["causes"][0] if action
      return attributes unless cause && cause["upstreamProject"] && cause["upstreamBuild"]

      attributes.merge(
        upstream_project_id: upstream_project_id(cause),
        upstream_build_id: upstream_build_id(cause),
      )
    end

    def upstream_build_id(cause)
      project_id = upstream_project_id(cause)
      build_id = StatsDb::Build.where(project_id: project_id, ci_id: cause["upstreamBuild"]).select_map(:id).first
      return build_id if build_id
      case @upstream_strategy
      when :fetch
        build_json = DataFetcher.new(cause["upstreamProject"]).get_build(cause["upstreamBuild"])
        upstream_build = self.class.new(build_json: build_json).execute
        upstream_build.id
      end
    end

    def upstream_project_id(cause)
      @_upstream_project_id ||= begin
        project_id = StatsDb::Project.where(name: cause["upstreamProject"]).select_map(:id).first
        return project_id if project_id
        case @upstream_strategy
        when :fetch
          upstream_project = StatsDb::Project.find_or_create(name: cause["upstreamProject"])
          upstream_project.id
        end
      end
    end

    def process_rspec_json(build, rspec_json)
      return if rspec_json.blank?
      (rspec_json["examples"] || []).each do |example|
        spec = StatsDb::Spec.find_or_create(project: @project, file_path: example["file_path"])
        spec_case = StatsDb::SpecCase.find_or_create(spec: spec, description: example["full_description"])

        spec_case.add_spec_case_run(
          build: build,
          status: example["status"],
          exception: example["exception"],
          run_time: example["run_time"],
          line_number: example["line_number"],
        )
      end
    end
  end
end
