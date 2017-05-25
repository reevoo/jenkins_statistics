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
