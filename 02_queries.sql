
-- =====================================================
-- CareLoop Clinics - No-Show Guard
-- Part 2: SQL Analysis
-- =====================================================

USE noshowguard;

-- Task: Primary Key constraint validation
-- Attempted to insert duplicate appointment_id A0001.
-- Expected result: MySQL rejected the duplicate.

-- Actual error:
-- Error Code: 1062. Duplicate entry 'A0001'
-- for key 'appointments.PRIMARY'
-- We can use the below query to reproduce the duplicate record entry error.
-- Task: Primary Key constraint validation
-- Attempt to insert an appointment with an existing appointment_id.
-- Expected result: MySQL should reject the duplicate primary key.

INSERT INTO appointments (
    appointment_id,
    patient_id,
    clinic_id,
    booked_on,
    appt_date,
    age,
    gender,
    distance_km,
    fee_inr,
    booking_channel,
    visit_type,
    reminder_sent,
    prior_no_shows,
    status,
    lead_days,
    no_show
)
VALUES (
    'A0001',
    'P0001',
    'C01',
    '2025-01-01',
    '2025-01-05',
    35,
    'F',
    5.0,
    500,
    'App',
    'General',
    'Yes',
    0,
    'Attended',
    4,
    0
);



-- Task: Clinic-wise no-show rate
-- Show clinics with at least 100 appointments.

SELECT
    c.clinic_id,
    c.clinic_name,
    c.city,
    COUNT(a.appointment_id) AS total_appointments,
    SUM(a.no_show) AS total_no_shows,
    ROUND(SUM(a.no_show) * 100.0 / COUNT(a.appointment_id), 1)
        AS no_show_rate
FROM clinics c
JOIN appointments a
    ON c.clinic_id = a.clinic_id
GROUP BY c.clinic_id, c.clinic_name, c.city
HAVING COUNT(a.appointment_id) >= 100
ORDER BY no_show_rate DESC;


-- Task: No-show rate by appointment lead-time band

SELECT
    lead_time_band,
    COUNT(*) AS total_appointments,
    SUM(no_show) AS total_no_shows,
    ROUND(SUM(no_show) * 100.0 / COUNT(*), 1) AS no_show_rate
FROM (
    SELECT
        CASE
            WHEN lead_days BETWEEN 1 AND 7 THEN '1-7 days'
            WHEN lead_days BETWEEN 8 AND 14 THEN '8-14 days'
            WHEN lead_days BETWEEN 15 AND 30 THEN '15-30 days'
            WHEN lead_days >= 31 THEN '31+ days'
        END AS lead_time_band,
        CASE
            WHEN lead_days BETWEEN 1 AND 7 THEN 1
            WHEN lead_days BETWEEN 8 AND 14 THEN 2
            WHEN lead_days BETWEEN 15 AND 30 THEN 3
            WHEN lead_days >= 31 THEN 4
        END AS band_order,
        no_show
    FROM appointments
) AS lead_time_data
GROUP BY lead_time_band, band_order
ORDER BY band_order;


-- Task: Monthly no-show trend using CTE and LAG()

WITH monthly_summary AS (
    SELECT
        DATE_FORMAT(appt_date, '%Y-%m') AS appointment_month,
        COUNT(*) AS total_appointments,
        ROUND(SUM(no_show) * 100.0 / COUNT(*), 1) AS no_show_rate
    FROM appointments
    GROUP BY DATE_FORMAT(appt_date, '%Y-%m')
),
monthly_comparison AS (
    SELECT
        appointment_month,
        total_appointments,
        no_show_rate,
        LAG(no_show_rate) OVER (
            ORDER BY appointment_month
        ) AS previous_month_rate
    FROM monthly_summary
)
SELECT
    appointment_month,
    total_appointments,
    no_show_rate,
    ROUND(no_show_rate - previous_month_rate, 1)
        AS change_vs_previous_month
FROM monthly_comparison
ORDER BY appointment_month;


-- Task: Rank clinics within each city and compare with overall rate

WITH clinic_summary AS (
    SELECT
        c.clinic_id,
        c.clinic_name,
        c.city,
        COUNT(a.appointment_id) AS total_appointments,
        SUM(a.no_show) AS total_no_shows,
        ROUND(SUM(a.no_show) * 100.0 / COUNT(a.appointment_id), 2)
            AS no_show_rate
    FROM clinics c
    JOIN appointments a
        ON c.clinic_id = a.clinic_id
    GROUP BY c.clinic_id, c.clinic_name, c.city
),
overall_summary AS (
    SELECT
        ROUND(SUM(no_show) * 100.0 / COUNT(*), 2)
            AS overall_no_show_rate
    FROM appointments
)
SELECT
    cs.clinic_name,
    cs.city,
    cs.total_appointments,
    cs.total_no_shows,
    cs.no_show_rate,
    RANK() OVER (
        PARTITION BY cs.city
        ORDER BY cs.no_show_rate DESC
    ) AS city_rank,
    os.overall_no_show_rate,
    ROUND(cs.no_show_rate - os.overall_no_show_rate, 2)
        AS difference_from_overall
FROM clinic_summary cs
CROSS JOIN overall_summary os
ORDER BY cs.city, city_rank;


