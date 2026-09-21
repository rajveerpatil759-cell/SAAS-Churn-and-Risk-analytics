-- =============================================================================
-- SAAS PROJECT — Feature Engineering
-- =============================================================================
-- Purpose : Build account_level_features, a leakage-safe, one-row-per-account
--           ML-ready table that aggregates subscriptions, feature usage, and
--           support tickets.
--
-- Input tables (created by raven_data_loading.ipynb + SQL cleaning):
--   accounts_clean, subscriptions_clean, feature_usage_clean,
--   support_tickets_clean, churn_events_clean

-- =============================================================================


-- =============================================================================
-- SECTION 1 — Build account_level_features
-- =============================================================================

DROP TABLE IF EXISTS account_level_features;

CREATE TABLE account_level_features AS

WITH current_subscription AS (
    -- Latest subscription record per account
    SELECT *
    FROM (
        SELECT
            *,
            ROW_NUMBER() OVER (
                PARTITION BY account_id
                ORDER BY start_date::date DESC
            ) AS rn
        FROM subscriptions_clean
    ) s
    WHERE rn = 1
),

usage_features AS (
    -- Aggregate all feature usage across all subscriptions per account
    SELECT
        s.account_id,
        COUNT(DISTINCT fu.usage_id)      AS total_usage_records,
        COUNT(DISTINCT fu.feature_name)  AS unique_features_used,
        SUM(fu.usage_count)              AS total_usage_count,
        SUM(fu.usage_duration_secs)      AS total_usage_duration_secs,
        SUM(fu.error_count)              AS total_errors
    FROM subscriptions_clean s
    JOIN feature_usage_clean fu
        ON s.subscription_id = fu.subscription_id
    GROUP BY s.account_id
),

support_features AS (
    -- Aggregate support ticket metrics per account
    SELECT
        account_id,
        COUNT(*)                                                AS total_tickets,
        ROUND(AVG(resolution_time_hours)::numeric, 2)          AS avg_resolution_time_hours,
        ROUND(AVG(first_response_time_minutes)::numeric, 2)    AS avg_first_response_minutes,
        ROUND(AVG(satisfaction_score)::numeric, 2)             AS avg_satisfaction_score,
        COUNT(*) FILTER (WHERE escalation_flag = true)         AS escalated_tickets
    FROM support_tickets_clean
    GROUP BY account_id
),

first_churn AS (
    -- Used only to compute a fair tenure for churned accounts
    SELECT
        account_id,
        MIN(churn_date::date) AS first_churn_date
    FROM churn_events_clean
    GROUP BY account_id
),


snapshot_date AS (
    SELECT GREATEST(
        (SELECT MAX(COALESCE(end_date, start_date)) FROM subscriptions_clean),
        (SELECT MAX(usage_date) FROM feature_usage_clean),
        (SELECT MAX(submitted_at) FROM support_tickets_clean),
        (SELECT MAX(churn_date) FROM churn_events_clean)
    )::date AS snapshot_date
)

SELECT
    -- Account identity
    a.account_id,
    a.industry,
    a.country,
    a.signup_date::date        AS signup_date,
    a.referral_source,
    a.is_trial,
    a.churn_flag,              -- TARGET VARIABLE

    -- Current subscription features
    cs.plan_tier,
    cs.seats,
    cs.mrr_amount,
    cs.arr_amount,
    cs.billing_frequency,
    cs.auto_renew_flag,
    cs.upgrade_flag,
    cs.downgrade_flag,

    -- Tenure (uses churn date for churned accounts to avoid inflating tenure)
    CASE
        WHEN a.churn_flag = TRUE
            THEN fc.first_churn_date - a.signup_date::date
        ELSE sd.snapshot_date - a.signup_date::date
    END AS customer_tenure_days,

    -- Feature usage (0 for accounts with no usage records)
    COALESCE(uf.total_usage_records,        0) AS total_usage_records,
    COALESCE(uf.unique_features_used,       0) AS unique_features_used,
    COALESCE(uf.total_usage_count,          0) AS total_usage_count,
    COALESCE(uf.total_usage_duration_secs,  0) AS total_usage_duration_secs,
    COALESCE(uf.total_errors,               0) AS total_errors,

    -- Support (NULL for accounts that never opened a ticket; imputed in Python)
    COALESCE(sf.total_tickets,    0) AS total_tickets,
    sf.avg_resolution_time_hours,
    sf.avg_first_response_minutes,
    sf.avg_satisfaction_score,
    COALESCE(sf.escalated_tickets, 0) AS escalated_tickets

FROM accounts_clean a
LEFT JOIN current_subscription cs ON a.account_id = cs.account_id
LEFT JOIN usage_features        uf ON a.account_id = uf.account_id
LEFT JOIN support_features      sf ON a.account_id = sf.account_id
LEFT JOIN first_churn           fc ON a.account_id = fc.account_id
CROSS JOIN snapshot_date        sd;


-- =============================================================================
-- SECTION 2 — Validate the output table
-- =============================================================================

-- Row count and uniqueness check
SELECT
    COUNT(*)                            AS total_rows,
    COUNT(DISTINCT account_id)          AS unique_accounts,
    COUNT(*) - COUNT(DISTINCT account_id) AS duplicate_rows
FROM account_level_features;

-- Churn flag distribution
SELECT
    churn_flag,
    COUNT(*) AS accounts,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM account_level_features
GROUP BY churn_flag
ORDER BY churn_flag;

-- Null check on key columns
SELECT
    COUNT(*) FILTER (WHERE plan_tier IS NULL)                 AS null_plan_tier,
    COUNT(*) FILTER (WHERE mrr_amount IS NULL)                AS null_mrr,
    COUNT(*) FILTER (WHERE customer_tenure_days IS NULL)      AS null_tenure,
    COUNT(*) FILTER (WHERE avg_satisfaction_score IS NULL)    AS null_satisfaction,
    COUNT(*) FILTER (WHERE avg_resolution_time_hours IS NULL) AS null_resolution_time
FROM account_level_features;

-- Sample output
SELECT *
FROM account_level_features
ORDER BY account_id
LIMIT 10;


SELECT
    CASE WHEN churn_flag = TRUE THEN 'Churned' ELSE 'Retained' END AS status,
    COUNT(*) AS accounts,
    ROUND(AVG(customer_tenure_days), 1) AS avg_tenure_days,
    MIN(customer_tenure_days) AS min_tenure_days,
    MAX(customer_tenure_days) AS max_tenure_days
FROM account_level_features
GROUP BY churn_flag;
