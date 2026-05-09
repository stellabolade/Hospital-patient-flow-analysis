# 🏥 Hospital Patient Flow — Operational Analysis

**Team 3 | Dataverse Africa Internship | March 2026**

---

## 📌 Project Overview

This project presents a comprehensive SQL-based operational analysis of hospital patient flow using a dataset of **5,000 patient encounter records**. The goal was to answer 14 key business questions about admissions, length of stay, discharge patterns, and departmental performance — and to identify the hospital's biggest patient flow bottleneck.

**Tools Used:** PostgreSQL · Power BI · Microsoft Excel

---

## 📂 Repository Structure

```
hospital-patient-flow-analysis/
│
├── README.md
├── sql/
│   └── Hospital_patient_flow_analysis.sql      ← All queries including schema + VIEW
├── reports/
│   ├── Query_report.pdf                         ← Full business questions & SQL findings
│   └── summary.pdf                              ← Executive summary of key insights
├── data/
│   └── Query_output_workbook.xlsx               ← Query results exported from PostgreSQL
└── dashboard/
    └── Hospital_patient_flow_visualization.pbix ← Power BI dashboard
```

---

## 🗃️ Database Schema

Three tables were created and joined using a central SQL VIEW called `base`:

```sql
-- Admissions table (core table)
CREATE TABLE admissions(
    admission_id          INT,
    patient_id            INT,
    admission_datetime    TIMESTAMP,
    discharge_datetime    TIMESTAMP,
    admission_type        VARCHAR(30),
    department            VARCHAR(30),
    discharge_disposition VARCHAR(30)
);

-- Patients table
CREATE TABLE patients(
    patient_id  INT,
    age         INT,
    sex         VARCHAR(15)
);

-- Diagnosis table
CREATE TABLE diagnosis(
    diagnosis_id  INT,
    admission_id  INT,
    icd10_code    VARCHAR(30)
);
```

### 🔗 Entity Relationships
- `admissions` ↔ `diagnosis` — joined on `admission_id`
- `admissions` ↔ `patients` — joined on `patient_id`

### 🧱 The `base` VIEW
To avoid repetitive joins across all 14 queries, a reusable VIEW was created that:
- Calculates **Length of Stay (LOS)** using `CEILING(DATE_PART(...))`
- Maps **ICD-10 codes** to readable diagnosis names
- Segments patients into **age groups** (Pediatric, Young Adult, Adult, Middle Aged, Elderly)

---

## ❓ Business Questions Answered

| # | Question |
|---|---|
| 1 | How many patients are admitted to the hospital each day? |
| 2 | What is the overall average length of stay (LOS)? |
| 3 | How does average LOS vary by department? |
| 4 | How are admissions distributed by admission type? |
| 5 | Which admission type is associated with the longest average LOS? |
| 6 | How do discharge dispositions break down across all admissions? |
| 7 | Do certain discharge dispositions correspond to longer hospital stays? |
| 8 | At what hours of the day do most admissions occur? |
| 9 | Are there specific days of the week with consistently higher admissions? |
| 10 | Which departments experience the highest admission volume? |
| 11 | How does patient age relate to length of stay? |
| 12 | Are older patients more likely to be discharged to rehab or skilled nursing? |
| 13 | Which diagnoses are most commonly associated with hospital admissions? |
| 14 | Do certain diagnoses result in longer average hospital stays? |

---

## 📊 Key Findings

### Admissions & Volume
- Daily admissions are steady at **5–20 patients/day**, with occasional spikes above 20.
- **Emergency admissions dominate at 55%** (2,755 cases), followed by Elective at 30% (1,478) and Urgent at 15% (767).
- **Orthopedics (895)** and **Pediatrics (884)** record the highest departmental volumes.

### Length of Stay (LOS)
- The overall **average LOS is approximately 4 days** — consistent across all departments (range: 3.9–4.2 days).
- **Urgent admissions** have the longest average LOS at **4.3 days**, despite being the smallest admission group — meaning they disproportionately occupy beds.
- **Young adults (19–35)** have the longest age-group LOS at **4.26 days**; Middle-aged patients have the shortest at **3.63 days**.

### Discharge Patterns
- **Over 70% of patients are discharged home**, reflecting strong acute care outcomes.
- ~16% are discharged to **rehabilitation**, ~10% to **skilled nursing facilities**.
- Patients who passed away ("Expired") had the longest average stay at **4.35 days**.
- Older patients (65+) are more commonly discharged to **rehab (237 patients)** than skilled nursing (168 patients).

### Time-Based Patterns
- Peak admission hour: **5 AM**, with secondary peaks at **10 AM** and **8 PM**.
- Busiest days: **Sunday (737 admissions)** and **Friday (725 admissions)**.
- Quietest day: **Saturday (697 admissions)**.

### Diagnoses
- Most common: **A09 – Gastroenteritis (771)**, **E11 – Type II Diabetes (737)**, **N39 – UTI (734)**.
- Longest average LOS by diagnosis: **N39 – UTI (4.17 days)**; Shortest: **I10 – Hypertension (3.9 days)**.

---

## 🚧 Patient Flow Bottleneck — Key Conclusion

> *"The biggest bottleneck is not simply too many patients, but a flow management issue across the entire care pathway."*

The core challenge comes from three interacting factors:

1. **High, unpredictable inflow** — 55% emergency admissions make demand hard to forecast or control.
2. **Fixed, inflexible outflow** — Average LOS stays at ~4 days regardless of department or diagnosis, so bed turnover cannot flex quickly during surges.
3. **External discharge dependency** — A significant share of patients need rehab or skilled nursing placements post-discharge. Delays in securing these keep medically-ready patients occupying beds longer than necessary.

### Recommended Focus Areas
- Strengthen **early-morning staffing** to handle the 5 AM admission peak
- Improve **discharge coordination** with rehab and external care facilities
- Enhance **bed management systems** to increase turnover responsiveness during surge periods
- Balance **elective scheduling** to maintain flexibility when emergency demand spikes

---

## 🛠️ SQL Techniques Demonstrated

- `CREATE TABLE` — Schema design across 3 relational tables
- `CREATE VIEW` — Reusable base query with joins, calculated fields, and CASE logic
- `INNER JOIN` + `USING()` — Clean multi-table joins
- `DATE_PART`, `CEILING`, `EXTRACT`, `TO_CHAR` — Date and time manipulation
- `COUNT`, `AVG`, `ROUND` — Aggregation and rounding
- Subqueries for percentage calculations
- `CASE WHEN` — Conditional logic for age grouping and diagnosis name mapping
- `LIMIT` — Focused top-N analysis

---

## 📈 Dashboard

The cleaned query outputs were visualized in a **Power BI dashboard** (see `/dashboard/` folder), covering admission trends, LOS by department, discharge disposition breakdown, and peak admission timing.

---

## 👩‍💻 About

**Stella Omobolade Obase**
Data Analyst Intern — Dataverse Africa
📅 April, 2026

*Project focus: Translating raw hospital records into operational insights using SQL and data visualization.*
