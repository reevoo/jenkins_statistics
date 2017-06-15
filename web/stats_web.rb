require "rubygems"
require "bundler/setup"

Bundler.require(:default)

$LOAD_PATH << File.expand_path("../", __FILE__)
$LOAD_PATH << File.expand_path("../../lib/", __FILE__)

ENV["RACK_ENV"] ||= "development"

if %w(development test).include? ENV["RACK_ENV"]
  require "pry"
  require "dotenv"
  case ENV["RACK_ENV"]
  when "test"
    Dotenv.load ".env.test"
  when "development"
    Dotenv.load ".env"
  end
end

require "active_support/all"
require "sinatra/base"

require "jenkins_statistics"


class StatsWeb < Sinatra::Application
  enable :logging

  def generate_punchcard(spec_case_id, builds, status_map = nil)
    if status_map
      Hash[builds.map do |b|
        [b.id, status_map[[spec_case_id, b.id]]]
      end]
    else
      Hash[builds.map do |b|
        [b.id, StatsDb::SpecCaseRun.where(build: b, spec_case_id: spec_case_id).select_map(:status).first]
      end]
    end
  end

  get "/" do
    @projects = StatsDb::Project.all
    slim :projects
  end

  get "/spec_case/:id/punchcard" do |id|
    @spec_case = StatsDb::SpecCase.find(id: id)
    builds = @spec_case.spec.project.builds

    @punchcard = generate_punchcard(@spec_case, builds)

    slim :punchcard
  end

  get "/spec/:id/punchcards" do |id|
    @owner = StatsDb::Spec.find(id: id)
    builds = @owner.project.builds

    @punchcards = @owner.spec_cases.each_with_object({}) do |sc, punchcards|
      punchcards[sc.description] = generate_punchcard(sc, builds)
    end

    slim :spec_punchcards
  end

  get "/projects/:name/punchcards" do |name|
    db = StatsDb::CONNECTION

    @project = StatsDb::Project.find(name: name)
    @builds = @project.builds_dataset.order(:ci_id)
    @builds = @builds.where("ci_id >= ?", params[:from].to_i) if params[:from]
    @builds = @builds.where("ci_id <= ?", params[:to].to_i) if params[:to]
    @builds = @builds.all
    status_map = {}
    @punchcards = {}

    if @project.upstream_project_id
      db.fetch("""
        SELECT sc.id, scr.build_id, scr.status
        FROM spec_case_runs scr
        JOIN spec_cases sc ON sc.id = scr.spec_case_id
        JOIN specs s ON s.id = sc.spec_id
        WHERE s.project_id = ?""", @project.id
      ) do |row|
        status_map[[row[:id], row[:build_id]]] = row[:status]
      end

      db.fetch("""
        SELECT s.file_path, sc.id, sc.description
        FROM spec_cases sc
        JOIN specs s ON s.id = sc.spec_id
        WHERE s.project_id = ?""", @project.id
      ) do |row|
        dsc = row[:description].truncate(100, omission: "...#{row[:description].last(50)}")
        @punchcards[dsc] = generate_punchcard(row[:id], @builds, status_map)
      end

    else
      db.fetch("""
        SELECT sc.id, b.upstream_build_id, scr.status
        FROM builds b
        JOIN spec_case_runs scr ON b.id = scr.build_id
        JOIN spec_cases sc ON sc.id = scr.spec_case_id
        JOIN specs s ON s.id = sc.spec_id
        WHERE b.upstream_build_id IN ?""", @builds.map(&:id)
      ) do |row|
        status_map[[row[:id], row[:upstream_build_id]]] = row[:status]
      end

      db.fetch("""
        SELECT DISTINCT s.file_path, sc.id, sc.description
        FROM builds b
        JOIN spec_case_runs scr ON b.id = scr.build_id
        JOIN spec_cases sc ON sc.id = scr.spec_case_id
        JOIN specs s ON s.id = sc.spec_id
        WHERE b.upstream_build_id IN ?""", @builds.map(&:id)
      ) do |row|
        dsc = row[:description].truncate(100, omission: "...#{row[:description].last(50)}")
        @punchcards[dsc] = generate_punchcard(row[:id], @builds, status_map)
      end
    end

    slim :project_punchcards
  end

    get "/most-flaky-specs" do
    @flaky_specs = StatsDb::CONNECTION.fetch("""
      SELECT p.name AS project, s.file_path, edges, last_failed
      FROM specs s
      JOIN projects p ON p.id = s.project_id
      JOIN (
        SELECT project_id, spec_id, count(*) AS edges, max(last_failed) AS last_failed FROM (
          SELECT project_id, spec_id, regexp_matches(results, '(01+0)', 'g'), last_failed FROM (
            SELECT project_id, spec_id, string_agg(status, '') AS results, max(last_failed) AS last_failed FROM (
              SELECT project_id, build_id, spec_id, (CASE WHEN failed_cases > 0 THEN '0' ELSE '1' END) AS status, last_failed FROM (
                SELECT b.project_id, b.id AS build_id, sc.spec_id, count(*) FILTER (WHERE scr.status = 'failed') AS failed_cases, max(scr.created_at) FILTER (WHERE scr.status = 'failed') AS last_failed
                  FROM spec_cases sc
                  JOIN spec_case_runs scr ON sc.id = scr.spec_case_id
                  JOIN builds b ON b.id = scr.build_id
                  GROUP BY 1,2,3
                  ORDER BY 1,2
                ) status_query
              ) agg_by_specs
            GROUP BY 1,2
          ) aggregated
        ) pattern_match
        GROUP BY 1,2
      ) counted_edges ON counted_edges.spec_id = s.id
      WHERE edges > 2
      ORDER BY edges desc;
    """).all

    slim :most_flaky_specs
  end


  get "/most-flaky-spec-cases" do
    @flaky_specs = StatsDb::CONNECTION.fetch("""
      SELECT p.name AS project, s.file_path, sc.description, edges, last_failed
      FROM spec_cases sc
      JOIN specs s ON s.id = sc.spec_id
      JOIN projects p ON p.id = s.project_id
      JOIN (
        SELECT project_id, spec_case_id, count(*) AS edges, max(last_failed) AS last_failed FROM (
          SELECT project_id, spec_case_id, regexp_matches(results, '(01+0)', 'g'), last_failed FROM (
            SELECT project_id, spec_case_id, string_agg(status, '') AS results, COUNT(*), max(created_at) AS last_failed FROM (
              SELECT b.project_id, b.id, sc.id AS spec_case_id, (CASE scr.status WHEN 'passed' THEN '1' WHEN 'failed' THEN '0' ELSE 'x' END) AS status, scr.created_at
              FROM spec_cases sc
              JOIN spec_case_runs scr ON sc.id = scr.spec_case_id
              JOIN builds b ON b.id = scr.build_id
              ORDER BY 1,2
            ) status_query
            GROUP BY 1,2
          ) aggregated
        ) pattern_match
        GROUP BY 1,2
      ) counted_edges ON counted_edges.spec_case_id = sc.id
      WHERE edges > 2
      ORDER BY edges desc;
    """).all

    slim :most_flaky_spec_cases
  end


  post "/build" do
    json = JSON.parse(request.body.read)
    Build::Process.new(build_json: json["build"], rspec_json: json["rspec"]).execute
    "Processed"
  end
end
