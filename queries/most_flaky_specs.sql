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
