-- -------
-- Query 8
-- -------

WITH mental_dx AS(
	SELECT DISTINCT subject_id
	FROM diagnosis_icd d JOIN icd_diagnosis i
		ON d.icd_code = i.icd_code AND d.icd_version = i.icd_version
	WHERE LOWER(long_title) LIKE '%depression%'
		OR LOWER(long_title) LIKE '%anxiety%'
		OR LOWER(long_title) LIKE '%mood%'
		OR LOWER(long_title) LIKE '% mental%'
		OR LOWER(long_title) LIKE '%bipolar%'
		OR LOWER(long_title) LIKE '%obsessive%'
		OR LOWER(long_title) LIKE '%ptsd%'
		OR LOWER(long_title) LIKE '%post-traumatic stress disorder%'
), all_immuno AS(
	SELECT subject_id, label, valuenum
	FROM labevents le JOIN labitems li ON le.itemid = li.itemid
	WHERE label = "immunoglobulin A" OR label = "cortisol"
)

SELECT
	CASE
		WHEN m.subject_id IS NOT NULL THEN 'Mental Health Diagnosis'
		ELSE 'No Mental Health Diagnosis'
	END AS mental_health_status,
	a.label,
	COUNT(DISTINCT a.subject_id) AS n_measurements,
	ROUND(AVG(a.valuenum), 2) AS avg_value
FROM all_immuno a
LEFT JOIN mental_dx m ON a.subject_id = m.subject_id
GROUP BY mental_health_status, a.label
ORDER BY label;
