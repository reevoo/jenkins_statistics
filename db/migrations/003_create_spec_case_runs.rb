Sequel.migration do
  up do
    create_enum :spec_case_run_status_enum, %w(passed failed pending)

    create_table :spec_case_runs do
      primary_key :id
      foreign_key :spec_case_id, :spec_cases, on_delete: :cascade
      foreign_key :build_id, :builds, on_delete: :cascade
      spec_case_run_status_enum :status
      column :exception, :jsonb
      Float :run_time
      DateTime :created_at, null: false
    end
  end

  down do
    drop_table :spec_case_runs, if_exists: true
    drop_enum :spec_case_run_status_enum
  end
end
