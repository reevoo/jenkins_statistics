Sequel.migration do
  up do
    create_table :projects do
      primary_key :id
      foreign_key :upstream_project_id, :projects
      String :name
    end

    create_enum :build_result_enum, %w(success failure aborted)

    create_table :builds do
      primary_key :id
      foreign_key :project_id, :projects
      foreign_key :upstream_build_id, :builds
      Integer :ci_id, null: false
      build_result_enum :result
      column :document, :jsonb, null: false
      column :rspec_json, :jsonb
      DateTime :timestamp, null: false
      DateTime :created_at, null: false
      index [:project_id, :ci_id], unique: true
    end
  end

  down do
    drop_table :builds, if_exists: true
    drop_table :projects, if_exists: true

    drop_enum :build_result_enum
  end
end
