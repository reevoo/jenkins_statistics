class StatsDb
  CONNECTION = Sequel.connect(ENV.fetch("DATABASE_URL"))
  Sequel::Model.plugin :timestamps
  CONNECTION.extension :pg_enum, :pg_array, :pg_json

  class Project < Sequel::Model
    one_to_many :builds
    one_to_many :downstream_builds, key: :upstream_project_id, class: :Build
    one_to_many :specs
    many_to_one :upstream_project, class: self
    one_to_many :downstream_projects, key: :upstream_project_id, class: self
  end

  class Build < Sequel::Model
    many_to_one :project
    many_to_one :upstream_project, class: :Project
    one_to_many :spec_case_runs
    many_to_one :upstream_build, class: self
    one_to_many :downstream_builds, key: :upstream_build_id, class: self
  end

  class Spec < Sequel::Model
    many_to_one :project
    one_to_many :spec_cases
  end

  class SpecCase < Sequel::Model
    many_to_one :spec
    one_to_many :spec_case_runs
  end

  class SpecCaseRun < Sequel::Model
    many_to_one :spec_case
    many_to_one :build
  end
end
