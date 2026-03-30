-- ============================================================
-- User Funnel & KPI Performance Analysis
-- Author: Gauri Sharan
-- Dataset: user_kpi_data.xlsx | 4,715 records | Jan–Mar 2024
-- ============================================================


-- ============================================================
-- SECTION 1: DATABASE & TABLE SETUP
-- ============================================================

CREATE DATABASE IF NOT EXISTS user_kpi_analysis;
USE user_kpi_analysis;

DROP TABLE IF EXISTS user_activity;

CREATE TABLE user_activity (
    user_id             VARCHAR(10),
    session_id          VARCHAR(10),
    event_date          DATE,
    funnel_stage        VARCHAR(20),
    product_id          VARCHAR(5),
    device_type         VARCHAR(10),
    region              VARCHAR(10),
    age_group           VARCHAR(10),
    session_duration_sec INT,
    page_views          INT,
    is_returning_user   TINYINT
);

-- After importing data from user_kpi_data.xlsx into this table, run sections below.


-- ============================================================
-- SECTION 2: DATA EXPLORATION
-- ============================================================

-- Total records
SELECT COUNT(*) AS total_records FROM user_activity;

-- Unique users and sessions
SELECT 
    COUNT(DISTINCT user_id)   AS unique_users,
    COUNT(DISTINCT session_id) AS unique_sessions
FROM user_activity;

-- Date range
SELECT 
    MIN(event_date) AS start_date,
    MAX(event_date) AS end_date
FROM user_activity;

-- Records per funnel stage
SELECT 
    funnel_stage,
    COUNT(*) AS record_count
FROM user_activity
GROUP BY funnel_stage
ORDER BY FIELD(funnel_stage, 'Visit','Signup','Add to Cart','Checkout','Purchase');

-- Device breakdown
SELECT 
    device_type,
    COUNT(DISTINCT user_id) AS users,
    ROUND(COUNT(DISTINCT user_id) * 100.0 / (SELECT COUNT(DISTINCT user_id) FROM user_activity), 1) AS pct
FROM user_activity
GROUP BY device_type
ORDER BY users DESC;


-- ============================================================
-- SECTION 3: FUNNEL ANALYSIS
-- ============================================================

-- Users at each funnel stage
SELECT
    funnel_stage,
    COUNT(DISTINCT user_id) AS users_at_stage
FROM user_activity
GROUP BY funnel_stage
ORDER BY FIELD(funnel_stage, 'Visit','Signup','Add to Cart','Checkout','Purchase');

-- Drop-off rate between each stage
WITH stage_counts AS (
    SELECT funnel_stage, COUNT(DISTINCT user_id) AS users
    FROM user_activity
    GROUP BY funnel_stage
),
ordered AS (
    SELECT
        funnel_stage,
        users,
        FIELD(funnel_stage, 'Visit','Signup','Add to Cart','Checkout','Purchase') AS stage_order
    FROM stage_counts
)
SELECT
    a.funnel_stage AS current_stage,
    a.users        AS current_users,
    b.users        AS previous_users,
    ROUND((b.users - a.users) * 100.0 / b.users, 1) AS drop_off_pct
FROM ordered a
JOIN ordered b ON a.stage_order = b.stage_order + 1
ORDER BY a.stage_order;

-- Step-to-step conversion rates
WITH visits AS (
    SELECT COUNT(DISTINCT user_id) AS v FROM user_activity WHERE funnel_stage = 'Visit'
),
signups AS (
    SELECT COUNT(DISTINCT user_id) AS s FROM user_activity WHERE funnel_stage = 'Signup'
),
carts AS (
    SELECT COUNT(DISTINCT user_id) AS c FROM user_activity WHERE funnel_stage = 'Add to Cart'
),
checkouts AS (
    SELECT COUNT(DISTINCT user_id) AS ch FROM user_activity WHERE funnel_stage = 'Checkout'
),
purchases AS (
    SELECT COUNT(DISTINCT user_id) AS p FROM user_activity WHERE funnel_stage = 'Purchase'
)
SELECT
    ROUND(s * 100.0 / v,  1) AS visit_to_signup_pct,
    ROUND(c * 100.0 / s,  1) AS signup_to_cart_pct,
    ROUND(ch * 100.0 / c, 1) AS cart_to_checkout_pct,
    ROUND(p * 100.0 / ch, 1) AS checkout_to_purchase_pct,
    ROUND(p * 100.0 / v,  1) AS overall_conversion_pct
FROM visits, signups, carts, checkouts, purchases;


-- ============================================================
-- SECTION 4: KPI METRICS
-- ============================================================

-- Core KPIs summary
SELECT
    COUNT(DISTINCT user_id)                                          AS total_users,
    COUNT(DISTINCT session_id)                                       AS total_sessions,
    COUNT(*)                                                         AS total_events,
    ROUND(AVG(session_duration_sec), 0)                             AS avg_session_duration_sec,
    ROUND(AVG(page_views), 1)                                       AS avg_page_views,
    SUM(is_returning_user)                                           AS returning_users,
    ROUND(AVG(is_returning_user) * 100, 1)                         AS returning_user_pct
FROM user_activity;

-- Engagement by device type
SELECT
    device_type,
    COUNT(DISTINCT user_id)           AS users,
    ROUND(AVG(session_duration_sec),0) AS avg_session_sec,
    ROUND(AVG(page_views),1)          AS avg_page_views
FROM user_activity
GROUP BY device_type
ORDER BY users DESC;

-- Engagement by age group
SELECT
    age_group,
    COUNT(DISTINCT user_id)            AS users,
    ROUND(AVG(session_duration_sec),0) AS avg_session_sec,
    ROUND(AVG(page_views),1)           AS avg_page_views
FROM user_activity
GROUP BY age_group
ORDER BY age_group;

-- Engagement by region
SELECT
    region,
    COUNT(DISTINCT user_id)            AS users,
    ROUND(AVG(session_duration_sec),0) AS avg_session_sec,
    ROUND(AVG(page_views),1)           AS avg_page_views
FROM user_activity
GROUP BY region
ORDER BY users DESC;


-- ============================================================
-- SECTION 5: PRODUCT PERFORMANCE
-- ============================================================

-- Total interactions per product
SELECT
    product_id,
    COUNT(*) AS total_interactions,
    COUNT(DISTINCT user_id) AS unique_users
FROM user_activity
GROUP BY product_id
ORDER BY total_interactions DESC;

-- Product conversion: users who reached Purchase stage
SELECT
    product_id,
    COUNT(DISTINCT CASE WHEN funnel_stage = 'Visit'        THEN user_id END) AS visitors,
    COUNT(DISTINCT CASE WHEN funnel_stage = 'Purchase'     THEN user_id END) AS purchasers,
    ROUND(
        COUNT(DISTINCT CASE WHEN funnel_stage = 'Purchase' THEN user_id END) * 100.0 /
        NULLIF(COUNT(DISTINCT CASE WHEN funnel_stage = 'Visit' THEN user_id END), 0),
    1) AS conversion_pct
FROM user_activity
GROUP BY product_id
ORDER BY conversion_pct DESC;


-- ============================================================
-- SECTION 6: DROP-OFF INSIGHTS
-- ============================================================

-- Users who dropped off at each stage (did not proceed further)
SELECT
    funnel_stage AS dropped_at_stage,
    COUNT(DISTINCT user_id) AS users_dropped
FROM user_activity ua
WHERE NOT EXISTS (
    SELECT 1 FROM user_activity ua2
    WHERE ua2.user_id = ua.user_id
      AND FIELD(ua2.funnel_stage, 'Visit','Signup','Add to Cart','Checkout','Purchase')
        > FIELD(ua.funnel_stage,  'Visit','Signup','Add to Cart','Checkout','Purchase')
)
GROUP BY funnel_stage
ORDER BY FIELD(funnel_stage, 'Visit','Signup','Add to Cart','Checkout','Purchase');

-- Drop-off by device at each stage
SELECT
    funnel_stage,
    device_type,
    COUNT(DISTINCT user_id) AS users
FROM user_activity
GROUP BY funnel_stage, device_type
ORDER BY FIELD(funnel_stage,'Visit','Signup','Add to Cart','Checkout','Purchase'), users DESC;

-- Drop-off by region at checkout (highest drop-off stage)
SELECT
    region,
    COUNT(DISTINCT CASE WHEN funnel_stage = 'Add to Cart' THEN user_id END) AS cart_users,
    COUNT(DISTINCT CASE WHEN funnel_stage = 'Checkout'    THEN user_id END) AS checkout_users,
    ROUND(
        COUNT(DISTINCT CASE WHEN funnel_stage = 'Checkout' THEN user_id END) * 100.0 /
        NULLIF(COUNT(DISTINCT CASE WHEN funnel_stage = 'Add to Cart' THEN user_id END), 0),
    1) AS cart_to_checkout_pct
FROM user_activity
GROUP BY region
ORDER BY cart_to_checkout_pct;


-- ============================================================
-- SECTION 7: TIME-BASED ANALYSIS
-- ============================================================

-- Daily activity trend
SELECT
    event_date,
    COUNT(*)                  AS total_events,
    COUNT(DISTINCT user_id)   AS active_users
FROM user_activity
GROUP BY event_date
ORDER BY event_date;

-- Weekly breakdown
SELECT
    WEEK(event_date)          AS week_number,
    COUNT(*)                  AS total_events,
    COUNT(DISTINCT user_id)   AS active_users,
    COUNT(DISTINCT CASE WHEN funnel_stage = 'Purchase' THEN user_id END) AS purchasers
FROM user_activity
GROUP BY WEEK(event_date)
ORDER BY week_number;

-- Monthly breakdown
SELECT
    DATE_FORMAT(event_date, '%Y-%m') AS month,
    COUNT(*)                          AS total_events,
    COUNT(DISTINCT user_id)           AS active_users,
    COUNT(DISTINCT CASE WHEN funnel_stage = 'Purchase' THEN user_id END) AS purchasers
FROM user_activity
GROUP BY month
ORDER BY month;


-- ============================================================
-- SECTION 8: KPI SUMMARY (Single Query)
-- ============================================================

SELECT
    (SELECT COUNT(DISTINCT user_id) FROM user_activity)                                          AS total_users,
    (SELECT COUNT(*) FROM user_activity)                                                          AS total_events,
    (SELECT COUNT(DISTINCT user_id) FROM user_activity WHERE funnel_stage = 'Visit')             AS visit_users,
    (SELECT COUNT(DISTINCT user_id) FROM user_activity WHERE funnel_stage = 'Signup')            AS signup_users,
    (SELECT COUNT(DISTINCT user_id) FROM user_activity WHERE funnel_stage = 'Add to Cart')       AS cart_users,
    (SELECT COUNT(DISTINCT user_id) FROM user_activity WHERE funnel_stage = 'Checkout')          AS checkout_users,
    (SELECT COUNT(DISTINCT user_id) FROM user_activity WHERE funnel_stage = 'Purchase')          AS purchase_users,
    ROUND(
        (SELECT COUNT(DISTINCT user_id) FROM user_activity WHERE funnel_stage = 'Purchase') * 100.0 /
        NULLIF((SELECT COUNT(DISTINCT user_id) FROM user_activity WHERE funnel_stage = 'Visit'), 0),
    1) AS overall_conversion_pct,
    ROUND((SELECT AVG(session_duration_sec) FROM user_activity), 0)                             AS avg_session_duration_sec,
    ROUND((SELECT AVG(page_views) FROM user_activity), 1)                                        AS avg_page_views,
    ROUND((SELECT AVG(is_returning_user) FROM user_activity) * 100, 1)                          AS returning_user_pct;
