class StatsDb
  CONNECTION = Sequel.connect(ENV.fetch('DATABASE_URL'))
  Sequel::Model.plugin :timestamps
  CONNECTION.extension :pg_enum, :pg_array, :pg_json

  class Project < Sequel::Model
    one_to_many :builds
    one_to_many :specs
  end

  class Build < Sequel::Model
    unrestrict_primary_key
    many_to_one :project
    one_to_many :spec_case_runs
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
