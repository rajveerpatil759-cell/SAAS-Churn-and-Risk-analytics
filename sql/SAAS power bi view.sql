
-- SAAS PROJECT — Power BI source view
-- =============================================================================
-- Purpose : Single, Power-BI-friendly view built on top of account_level_features.
--           

-- =============================================================================
 
DROP VIEW IF EXISTS powerbi_account_view;
 
CREATE VIEW powerbi_account_view AS
SELECT
    account_id,
    industry,
    country,
    referral_source,
    is_trial,
    churn_flag,
    CASE WHEN churn_flag = TRUE THEN 'Churned' ELSE 'Retained' END AS churn_status,
 
    plan_tier,
    seats,
    mrr_amount,
    arr_amount,
    billing_frequency,
    auto_renew_flag,
 
    customer_tenure_days,

    CASE
        WHEN customer_tenure_days <= 90  THEN '0-3 months'
        WHEN customer_tenure_days <= 180 THEN '3-6 months'
        WHEN customer_tenure_days <= 365 THEN '6-12 months'
        ELSE '12+ months'
    END AS tenure_group,
    
    CASE
        WHEN customer_tenure_days <= 90  THEN 1
        WHEN customer_tenure_days <= 180 THEN 2
        WHEN customer_tenure_days <= 365 THEN 3
        ELSE 4
    END AS tenure_sort_order,
 
    total_usage_records,
    unique_features_used,
    total_usage_count,
    total_usage_duration_secs,
    total_errors,
 
    total_tickets,
    avg_resolution_time_hours,
    avg_first_response_minutes,
    avg_satisfaction_score,
    escalated_tickets
 
FROM account_level_features;
 
-- Quick check after creating the view
SELECT * FROM powerbi_account_view LIMIT 10;

----
DROP VIEW IF EXISTS powerbi_segment_risk_view;
 
CREATE VIEW powerbi_segment_risk_view AS
WITH account_mrr AS (
    SELECT account_id, SUM(mrr_amount) AS total_mrr
    FROM subscriptions_clean
    GROUP BY account_id
)
SELECT
    a.industry,
    a.referral_source,
    COUNT(*) AS total_accounts,
    SUM(CASE WHEN a.churn_flag = TRUE THEN 1 ELSE 0 END) AS churned_accounts,
    ROUND(
        100.0 * SUM(CASE WHEN a.churn_flag = TRUE THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate_percentage,
    ROUND(
        SUM(CASE WHEN a.churn_flag = TRUE THEN am.total_mrr ELSE 0 END)::numeric,
        2
    ) AS churned_mrr
FROM accounts_clean a
JOIN account_mrr am ON a.account_id = am.account_id
GROUP BY a.industry, a.referral_source
-- Same noise filter as Q36 -- drops segments too small to trust
HAVING COUNT(*) >= 10
ORDER BY churned_mrr DESC;
 
SELECT * FROM powerbi_segment_risk_view ;