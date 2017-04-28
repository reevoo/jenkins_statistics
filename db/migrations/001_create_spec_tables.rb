Sequel.migration do
  up do
    create_table :projects do
      primary_key :id
      String :name
    end

    create_enum :build_result_enum, %w(success failure)

    create_table :builds do
      Integer :id, primary_key: true, null: false
      foreign_key :project_id, :projects
      build_result_enum :result
      column :document, :jsonb, null: false
      column :rspec_json, :jsonb
      DateTime :timestamp, null: false
      DateTime :created_at, null: false
    end

    create_table :specs do
      primary_key :id
      foreign_key :project_id, :projects
      String :file_path, null: false
      DateTime :created_at, null: false
      index [:project_id, :file_path], unique: true
    end

    create_table :spec_cases do
      primary_key :id
      foreign_key :spec_id, :specs
      String :description
      DateTime :created_at, null: false
      index [:spec_id, :description], unique: true
    end

    create_enum :spec_case_run_status_enum, %w(passed failed pending)

    create_table :spec_case_runs do
      primary_key :id
      foreign_key :spec_case_id, :spec_cases
      foreign_key :build_id, :builds
      spec_case_run_status_enum :status
      column :exception, :jsonb
      Float :run_time
      DateTime :created_at, null: false
    end
  end

  down do
    drop_table :spec_case_runs, if_exists: true
    drop_table :spec_cases, if_exists: true
    drop_table :specs, if_exists: true
    drop_table :builds, if_exists: true
    drop_table :projects, if_exists: true

    drop_enum :build_result_enum
    drop_enum :spec_case_run_status_enum
  end
end
