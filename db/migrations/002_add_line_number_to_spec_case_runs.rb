Sequel.migration do
  up do
    add_column :spec_case_runs, :line_number, Integer
  end

  down do
    remove_column :spec_case_runs, :line_number
  end
end
