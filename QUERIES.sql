SELECT
s.file_path,
COUNT(*) FILTER (WHERE scr.status = 'passed') AS passed_count,
COUNT(*) FILTER (WHERE scr.status = 'failed') AS failed_count
FROM specs s
JOIN spec_cases sc ON sc.spec_id = s.id
JOIN spec_case_runs scr ON scr.spec_case_id = sc.id
JOIN builds b ON scr.build_id = b.id
WHERE b.upstream_project_id = 5
GROUP BY s.file_path
ORDER BY failed_count DESC;


SELECT
s.file_path,
COUNT(*) FILTER (WHERE scr.status = 'passed') AS passed_count,
COUNT(*) FILTER (WHERE scr.status = 'failed') AS failed_count
FROM specs s
JOIN spec_cases sc ON sc.spec_id = s.id
JOIN spec_case_runs scr ON scr.spec_case_id = sc.id
JOIN builds b ON scr.build_id = b.id
WHERE b.project_id = 2
GROUP BY s.file_path
ORDER BY failed_count DESC;


SELECT
s.file_path,
sc.id,
sc.description,
COUNT(*) FILTER (WHERE scr.status = 'passed') AS passed_count,
COUNT(*) FILTER (WHERE scr.status = 'failed') AS failed_count
FROM specs s
JOIN spec_cases sc ON sc.spec_id = s.id
JOIN spec_case_runs scr ON scr.spec_case_id = sc.id
JOIN builds b ON scr.build_id = b.id
WHERE b.project_id = 2
GROUP BY 1,2,3
ORDER BY failed_count DESC;


SELECT
s.file_path,
sc.id,
sc.description,
COUNT(*) FILTER (WHERE scr.status = 'passed') AS passed_count,
COUNT(*) FILTER (WHERE scr.status = 'failed') AS failed_count
FROM specs s
JOIN spec_cases sc ON sc.spec_id = s.id
JOIN spec_case_runs scr ON scr.spec_case_id = sc.id
JOIN builds b ON scr.build_id = b.id
WHERE b.project_id = 2
GROUP BY 1,2,3
ORDER BY failed_count DESC;


SELECT * FROM spec_case_runs WHERE spec_case_id = 2958 AND status = 'failed';


SELECT
s.file_path,
sc.id,
sc.description,
COUNT(*) FILTER (WHERE scr.status = 'passed') AS passed_count,
COUNT(*) FILTER (WHERE scr.status = 'failed') AS failed_count
FROM specs s
JOIN spec_cases sc ON sc.spec_id = s.id
JOIN spec_case_runs scr ON scr.spec_case_id = sc.id
JOIN builds b ON scr.build_id = b.id
WHERE b.project_id = 2
AND (scr.exception IS NULL OR scr.exception->>'message' NOT LIKE '%Sapience%')
GROUP BY 1,2,3
ORDER BY failed_count DESC;


SELECT * FROM spec_case_runs WHERE spec_case_id = 4358 AND status = 'failed';


SELECT
s.file_path,
sc.id,
sc.description,
COUNT(*) AS failed_count
FROM specs s
JOIN spec_cases sc ON sc.spec_id = s.id
JOIN spec_case_runs scr ON scr.spec_case_id = sc.id
JOIN builds b ON scr.build_id = b.id
WHERE b.project_id = 2
AND scr.status = 'failed'
AND (scr.exception IS NULL OR scr.exception->>'message' NOT LIKE '%Sapience%')
GROUP BY 1,2,3
HAVING COUNT(*) > 1
ORDER BY failed_count DESC;



SELECT failed_cases.id, scr.exception, count(*) FROM (
SELECT
s.file_path,
sc.id,
sc.description,
COUNT(*) AS failed_count
FROM specs s
JOIN spec_cases sc ON sc.spec_id = s.id
JOIN spec_case_runs scr ON scr.spec_case_id = sc.id
JOIN builds b ON scr.build_id = b.id
WHERE b.project_id = 2
AND scr.status = 'failed'
GROUP BY 1,2,3
HAVING COUNT(*) > 1
ORDER BY failed_count DESC
) failed_cases
JOIN spec_case_runs scr ON scr.spec_case_id = failed_cases.id
WHERE scr.status = 'failed'
AND scr.exception->>'message' NOT LIKE '%Sapience%'
GROUP BY 1,2
HAVING count(*)
ORDER BY failed_cases.id
;


SELECT failed_cases.file_path, failed_cases.id, failed_cases.description, count(*) FROM
(
SELECT
s.file_path,
sc.id,
sc.description,
scr.exception,
COUNT(*) AS failed_count
FROM specs s
JOIN spec_cases sc ON sc.spec_id = s.id
JOIN spec_case_runs scr ON scr.spec_case_id = sc.id
JOIN builds b ON scr.build_id = b.id
WHERE b.project_id = 2
AND scr.status = 'failed'
AND scr.exception->>'message' NOT LIKE '%Sapience%'
GROUP BY 1,2,3,4
ORDER BY failed_count DESC
) failed_cases
GROUP BY 1,2,3
HAVING count(*) > 1
;


SELECT failed_cases.file_path, failed_cases.id, failed_cases.description, count(*) AS couses FROM
(
SELECT
s.file_path,
sc.id,
sc.description,
scr.exception->>'class',
substring(scr.exception->>'message' FROM 1 FOR 30),
COUNT(*) AS failed_count
FROM specs s
JOIN spec_cases sc ON sc.spec_id = s.id
JOIN spec_case_runs scr ON scr.spec_case_id = sc.id
JOIN builds b ON scr.build_id = b.id
WHERE b.project_id = 2
AND scr.status = 'failed'
AND scr.exception->>'message' NOT LIKE '%Sapience%'
GROUP BY 1,2,3,4,5
ORDER BY failed_count DESC
) failed_cases
GROUP BY 1,2,3
HAVING count(*) > 1
;



-- Get test results encoded into string for each specs case

SELECT project_id, spec_case_id, string_agg(status, '') AS results, COUNT(*) FROM (
  SELECT b.project_id, sc.id AS spec_case_id, b.ci_id, (CASE scr.status WHEN 'passed' THEN '1' WHEN 'failed' THEN '0' ELSE 'x' END) AS status
  FROM spec_cases sc
  LEFT JOIN spec_case_runs scr ON sc.id = scr.spec_case_id
  LEFT JOIN builds b ON b.id = scr.build_id
  ORDER BY 1,2
) status_query
GROUP BY 1,2;


-- Get most flaky spec cases based on number of edges

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
        -- WHERE b.project_id=11
        ORDER BY 1,2
      ) status_query
      GROUP BY 1,2
    ) aggregated
  ) pattern_match
  GROUP BY 1,2
) counted_edges ON counted_edges.spec_case_id = sc.id
ORDER BY edges desc;



-- Get most flaky specs based on number of edges aggregated over spec cases

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
            WHERE b.project_id=11
            GROUP BY 1,2,3
            ORDER BY 1,2
          ) status_query
        ) agg_by_specs
      GROUP BY 1,2
    ) aggregated
  ) pattern_match
  GROUP BY 1,2
) counted_edges ON counted_edges.spec_id = s.id
ORDER BY edges desc;




-- Get test results encoded into string for each specs case in project including skipped tests in build

SELECT spec_case_id, string_agg(status, '') AS results, COUNT(*) FROM (
SELECT comb.project_id, comb.spec_case_id, comb.build_ci_id, (CASE scr.status WHEN 'passed' THEN '1' WHEN 'failed' THEN '0' ELSE 'x' END) AS status
FROM spec_case_runs scr
RIGHT JOIN (
    SELECT b.project_id, b.id AS build_id, b.ci_id AS build_ci_id, sc.id AS spec_case_id
    FROM builds b
    CROSS JOIN (
        SELECT sc.* FROM spec_cases sc
        JOIN specs s ON s.id = sc.spec_id
        WHERE s.project_id = 11
    ) sc
    WHERE b.project_id = 11
) comb ON comb.spec_case_id = scr.spec_case_id AND comb.build_id = scr.build_id
-- ORDER BY 1,2
) status_query
GROUP BY 1;
