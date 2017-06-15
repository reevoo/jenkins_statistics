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
