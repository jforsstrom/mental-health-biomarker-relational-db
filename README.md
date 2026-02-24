# mental-health-biomarker-relational-db
This project implements a relational clinical research database in MySQL, integrating multimodal mental health data including patient demographics, admissions, laboratory biomarkers, diagnoses, survey assessments, and neuroimaging features. Built using a subset of MIMIC-IV data with supplementary schema extensions, the system enables structured querying of biomarker–diagnosis relationships and supports scalable analytical workflows in mental health research.

## Database Architecture
![Entity-Relationship Diagram](er_diagram.png)

## Core Entities

The database is structured around the following primary entities:

- **patient** – demographic and anchor information
- **admissions** – hospitalization events linked to each patient
- **diagnosis_icd / icd_diagnosis** – coded diagnoses using ICD-9/10 standards
- **labevents / labitems** – laboratory measurements including biomarkers (e.g., cortisol, immunoglobulin A)
- **prescriptions** – medication records associated with hospital admissions
- **patient_surveys** – standardized mental health assessments (e.g., GAD-7, PHQ-9)
- **neuro_imaging** – imaging-derived features such as microglial activation metrics

## Example Analytical Query

The following query compares average cortisol and immunoglobulin A levels between patients with and without a mental health diagnosis.

```sql
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
