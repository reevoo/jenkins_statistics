Sequel.migration do
  up do
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
  end

  down do
    drop_table :spec_cases, if_exists: true
    drop_table :specs, if_exists: true
  end
end
