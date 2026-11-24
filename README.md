# CareLoop Clinics — No-Show Guard

**From raw appointment bookings to no-show risk prediction and AI-assisted patient follow-up analysis.**

## 1. Project Overview

CareLoop Clinics operates 8 outpatient clinics across 6 Indian cities. Missed appointments affect clinic capacity, operational efficiency, and patient access to healthcare.

This project investigates:

- Which appointments are most likely to be missed?
- What factors are associated with missed appointments?
- How can clinics prioritise follow-up interventions?
- Can Generative AI help categorise patient follow-up notes and recommend practical actions?

The project covers data processing, SQL analytics, machine learning, and Generative AI.

## 2. Project Structure

```text
careloop-no-show-guard/
│
├── data/
│   ├── appointments.csv
│   ├── clinics.csv
│   └── followup_notes.csv
│
├── 01_ingest_clean.ipynb
├── rejected_rows.json
├── appointments_clean.csv
├── clinics_enriched.csv
├── load_data.sql
│
├── 02_queries.sql
│
├── 03_model.ipynb
├── test_risk_scores.csv
│
├── 04_genai.ipynb
├── notes_analysed.csv
│
├── README.md
└── .gitignore
```

## 3. Work Completed and Key Findings

### Part 1 — Python and Data Foundations

- Processed 1,020 raw appointment records.
- Retained 990 cleaned appointment records after data-quality checks.
- Identified and handled missing values, duplicate records, invalid ages, and outliers.
- Created derived features including `lead_days` and `no_show`.
- Enriched 8 clinic records with weather information.

**Key finding:** 218 of 990 appointments were missed, representing a 22.0% no-show rate.

### Part 2 — SQL Analytics

Created a MySQL database with clinic and appointment tables and implemented:

- Clinic-wise no-show rates.
- Lead-time band analysis.
- Monthly no-show trends using CTEs and LAG.
- City-wise clinic rankings using window functions.
- Primary-key duplicate validation.

**Key finding:** Appointments booked 31 or more days in advance had a 60.5% no-show rate, compared with 16.2% for appointments booked 1–7 days ahead.

### Part 3 — Machine Learning

Compared Logistic Regression, Decision Tree, and Random Forest models. Used cross-validation and GridSearchCV for model evaluation and tuning.

**Selected model:** Logistic Regression with a classification threshold of 0.30.

| Metric | Test result |
|---|---:|
| Accuracy | 79.29% |
| Precision | 57.14% |
| Recall | 65.31% |
| F1-score | 60.95% |
| ROC-AUC | 0.7889 |

The selected threshold detected 32 of the 49 actual no-shows in the test set.

Generated `test_risk_scores.csv` containing appointment IDs, actual outcomes, predicted risk probabilities, and risk flags.

### Part 4 — Generative AI

Integrated the Gemini API to analyse patient follow-up notes.

Implemented:

- A structured CRAFT prompt.
- Root-cause classification into six predefined categories.
- Pydantic validation of AI-generated JSON responses.
- Handling of blank notes and invalid model responses.
- Comparison of simple prompting (V1) with CRAFT prompting (V2).

**Key findings:**

- Analysed 10 notes; 9 nonblank notes were successfully classified.
- All 9 successful classifications matched the expected categories in the sample.
- Both V1 and V2 correctly classified the two prompt-comparison examples.
- CRAFT produced more specific operational recommendations in these examples.

Generated `notes_analysed.csv` with root-cause classifications, confidence scores, summaries, and recommended actions.

## 4. Business Recommendations

CareLoop should prioritise early follow-up for appointments booked more than 14 days in advance, as this group had a 30.0% no-show rate, increasing to 60.5% for bookings made 31+ days ahead. The selected Logistic Regression model achieved a ROC-AUC of 0.7889 and, at a 0.30 threshold, detected 32 of 49 test-set no-shows. Clinics could use the risk scores to prioritise calls and reminder checks, while reviewing transport, cost, illness, and work-related barriers identified in follow-up notes. The clinic-level analysis also highlights variation in no-show rates, from 13.8% at Vaishali Nagar to 33.3% at Gomti Nagar. These findings support targeted interventions rather than applying the same follow-up process to every patient.

## 5. Limitations and Responsible Use

1. **Dataset limitations:** The analysis uses 990 cleaned appointments and a limited set of follow-up notes. Findings may not generalise to other clinics or populations.
2. **Model limitations:** The model's predictions are based on historical patterns. Observational relationships, including the association between reminders and attendance, do not establish causation. The selected threshold also involves a precision-recall trade-off.
3. **Generative AI limitations:** AI-generated root causes and recommendations can be incomplete or incorrect. Human review is necessary, especially when notes are ambiguous.

The risk model and AI-generated recommendations are intended as operational decision-support tools, not as replacements for clinic staff or clinical judgement. Real patient information should only be processed through AI services with appropriate organisational approval and privacy safeguards.

## 6. Technologies Used

- Python
- Pandas and NumPy
- Matplotlib / Seaborn (where applicable)
- Scikit-learn
- MySQL 8 and MySQL Workbench
- Google Colab
- Gemini API (`google-genai`)
- Pydantic
- Git and GitHub

## 7. How to Explore the Project

1. Start with `01_ingest_clean.ipynb` for data ingestion and cleaning.
2. Review `02_queries.sql` for SQL analysis.
3. Explore `03_model.ipynb` for model development and evaluation.
4. Explore `04_genai.ipynb` for AI-assisted note analysis.

The notebooks contain the implementation, validation outputs, and explanations for each stage.
