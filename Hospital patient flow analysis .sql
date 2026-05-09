-- Creating diagnosis table

CREATE TABLE diagnosis(
diagnosis_id INT,
admission_id INT,	
icd10_code VARCHAR(30));

--creating patients table
CREATE TABLE patients(
patient_id	INT,
age	INT, 
sex VARCHAR(15)
);

--Creating admissions table

CREATE TABLE admissions(
admission_id INT,
patient_id	INT,
admission_datetime TIMESTAMP,
discharge_datetime TIMESTAMP,
admission_type	VARCHAR(30),
department	VARCHAR(30),
discharge_disposition VARCHAR(30)
);

--Investigating total admission entry

SELECT 
		COUNT(*) AS admission_count-- 5000 entry
FROM admissions;


--Investigating total patients entry

SELECT 
		COUNT(*) AS patients_count-- 5000 patients entry
FROM patients
SELECT * FROM patients;

--Investigating total diagnosis entry

SELECT 
		COUNT(*) AS diagnosis_count-- 5000 diagnosis entry
FROM diagnosis;
SELECT * FROM diagnosis


CREATE VIEW base AS (
	SELECT 
			a.admission_id,
			a.patient_id,
			a.admission_datetime AS admission_date,
			a.discharge_datetime AS discharge_date,
			CEILING(DATE_PART('day', a.discharge_datetime - a.admission_datetime)) AS LOS,
			a.admission_type,
			a.department,
			a.discharge_disposition,
			d.diagnosis_id,
			d.icd10_code,
		CASE
				WHEN d.icd10_code = 'A09' THEN 'Gastroenteritis'
				WHEN d.icd10_code = 'E11' THEN 'DM ii'
				WHEN d.icd10_code = 'N39' THEN 'UTI.u'
				WHEN d.icd10_code = 'I10' THEN 'Hypertension.p'
				WHEN d.icd10_code  = 'J18' THEN 'Pneumonia.u'
				WHEN d.icd10_code = 'K35' THEN 'Appendicitis.a'
				ELSE 'Other' END AS diagnosis_name,
			p.age,
			p.sex,
			CASE
		WHEN p.age  BETWEEN 0 AND  18 THEN 'Pediatric'
		WHEN p.age BETWEEN 19 AND  35 THEN 'Young Adult'
		WHEN p.age BETWEEN 36 AND 50 THEN 'Adult'
		WHEN p.age BETWEEN 51 AND 65 THEN 'Middle Aged'
		ELSE 'Ederly'
	END AS age_group
	FROM admissions a
	INNER JOIN diagnosis d
	USING(admission_id)
	INNER JOIN patients p
	USING(patient_id)
			);

	SELECT * FROM base;
	
-- NB: Admission table connected to patients table and diagnosis table through patients_id and diagnosis_id.
--Business Questions	

--1. How many patients are admitted to the hospital each day?

SELECT 
		Date(admission_date) AS admission_date,
		COUNT(*) AS patients_count
FROM base
GROUP BY Date(admission_date)
ORDER BY patients_count DESC;

SELECT 
       DATE(admission_datetime) AS admission_date,
       Count (*) AS admission_count
FROM admissions
GROUP BY DATE(admission_datetime)
ORDER BY admission_date;

--2. What is the overall average length of stay (LOS) for admitted patients?             

SELECT
	ROUND(AVG(LOS)::numeric, 2) AS avg_los
FROM base;

--3. How does average length of stay vary by department?

SELECT 
	department,
	ROUND(AVG(LOS)::numeric, 2) AS avg_los
FROM base
GROUP BY department
ORDER BY avg_LOS DESC; 


--4. How are admissions distributed by admission type?

SELECT 
	admission_type,
	COUNT(*) AS admission_count
FROM base
GROUP BY admission_type
ORDER BY admission_count DESC;

--5. Which admission type is associated with the longest average length of stay?
SELECT 
	admission_type,
	ROUND(AVG(LOS)::numeric, 2) AS avg_los
FROM base
GROUP BY admission_type
ORDER BY avg_LOS DESC;

--6. How do discharge dispositions break down across all admissions? Hint: (GROUP BY, COUNT, Percentage)
SELECT 
	discharge_disposition,
	COUNT(*) AS total_count,
	ROUND((count(*)*100) / (SELECT count(*) FROM admissions),2) || '%' AS disposition_pct
FROM admissions
GROUP BY discharge_disposition
ORDER BY disposition_pct DESC;

--7. Do certain discharge dispositions correspond to longer hospital stays?
SELECT 
	discharge_disposition,
	COUNT(*) AS total_count,
	ROUND((COUNT(*) * 100.00) / (SELECT COUNT(*) FROM admissions),2) || '%' AS disposition_pct,
	ROUND(AVG(LOS)::numeric, 2) AS avg_los
FROM base
GROUP BY discharge_disposition
ORDER BY  avg_LOS DESC;

--8. At what hours of the day do most admissions occur?

SELECT 
    EXTRACT(HOUR FROM admission_date) AS hour_24,
    TO_CHAR(admission_date, 'HH12 AM') AS hour_12,
    COUNT(*) AS admission_count
FROM base
GROUP BY hour_24, hour_12
ORDER BY admission_count DESC;

--9. Are there specific days of the week with consistently higher admissions?(DOW: 0= Sunday, 6 = Saturday)

SELECT
	EXTRACT(DOW FROM admission_date) AS day_num,
	TO_CHAR(admission_date, 'Day') AS day_name,
	COUNT(*) AS patients_count
FROM base
GROUP BY day_name, day_num
ORDER BY patients_count DESC;

--10. Which departments experience the highest admission volume? (Top 5 is sufficient so that the signal isn’t weakened)

SELECT 
	Department,
	COUNT(*) AS patients_count
FROM base
GROUP BY department
ORDER BY patients_count DESC
LIMIT 5;

--11. How does patient age relate to length of stay? (Should I give you hint 🤔?)

SELECT 
	 age_group,
	ROUND(AVG(LOS)::numeric, 2) AS avg_los,
	COUNT(*) AS patients_count
FROM base
WHERE discharge_date >= admission_date
GROUP BY age_group
ORDER BY avg_los DESC;

--12. Are older patients more likely to be discharged to rehab or skilled nursing?

SELECT 
    CASE 
        WHEN age < 65 THEN '<65' 
        WHEN age >= 65 THEN '65+'
    END AS age_band,
	COUNT(*) AS total_patients,
	ROUND(COUNT(CASE WHEN discharge_disposition IN ('Skilled Nursing', 'Rehab') THEN 1 END) * 100.0 / COUNT(*),2)  || '%' AS sn_rh_pct 
FROM base
GROUP BY age_band
ORDER BY age_band;

--13. Which diagnoses are most commonly associated with hospital admissions?

 SELECT 
	 diagnosis_name,
 	 icd10_code, 
	 ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM diagnosis),2) || '%' AS icd10_pct,
 	COUNT(*) AS patients_cnt 
 FROM base
 GROUP BY icd10_code, diagnosis_name
 ORDER BY icd10_pct DESC;

 --14. Do certain diagnoses result in longer average hospital stays?
 SELECT 
 	icd10_code, 
 	COUNT(*) AS patients_cnt,
	ROUND(AVG(LOS)::numeric, 2) AS avg_los
 FROM base
 WHERE discharge_date IS NOT NULL
 GROUP BY icd10_code
 ORDER BY avg_LOS DESC;
