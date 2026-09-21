-- =============================================================================
-- SAAS PROJECT — Business Questions
-- =============================================================================
-- Purpose : Answer 45 business questions across five domains:
--           subscriptions, accounts, churn, feature usage, and support.

-- =============================================================================


-- =============================================================================
-- SECTION 0 — Row counts (sanity check)
-- =============================================================================

SELECT 'accounts_clean'       AS table_name, COUNT(*) AS row_count FROM accounts_clean
UNION ALL
SELECT 'subscriptions_clean',  COUNT(*) FROM subscriptions_clean
UNION ALL
SELECT 'feature_usage_clean',  COUNT(*) FROM feature_usage_clean
UNION ALL
SELECT 'support_tickets_clean',COUNT(*) FROM support_tickets_clean
UNION ALL
SELECT 'churn_events_clean',   COUNT(*) FROM churn_events_clean;


-- =============================================================================
-- SECTION 1 — Subscription Analysis
-- =============================================================================

-- Q1. Total MRR across all subscription records
SELECT SUM(mrr_amount) AS total_mrr
FROM subscriptions_clean;

-- Q2. MRR contribution by plan tier
SELECT
    plan_tier,
    COUNT(*)                         AS subscription_count,
    SUM(mrr_amount)                  AS total_mrr,
    ROUND(AVG(mrr_amount), 2)        AS avg_mrr
FROM subscriptions_clean
GROUP BY plan_tier
ORDER BY total_mrr DESC;

-- Q3. Average MRR per subscription by plan tier
SELECT
    plan_tier,
    ROUND(AVG(mrr_amount), 2) AS avg_mrr
FROM subscriptions_clean
GROUP BY plan_tier
ORDER BY avg_mrr DESC;

-- Q4. Subscription count by plan tier
SELECT
    plan_tier,
    COUNT(*) AS subscription_count
FROM subscriptions_clean
GROUP BY plan_tier
ORDER BY subscription_count DESC;

-- Q5. ARR by plan tier
SELECT
    plan_tier,
    SUM(arr_amount)           AS total_arr,
    ROUND(AVG(arr_amount), 2) AS avg_arr
FROM subscriptions_clean
GROUP BY plan_tier
ORDER BY total_arr DESC;

-- Q6. Trial vs paid subscriptions
SELECT
    is_trial,
    COUNT(*) AS subscription_count
FROM subscriptions_clean
GROUP BY is_trial
ORDER BY is_trial;

-- Q7. Subscriptions by plan tier and trial status
SELECT
    plan_tier,
    is_trial,
    COUNT(*) AS subscription_count
FROM subscriptions_clean
GROUP BY plan_tier, is_trial
ORDER BY plan_tier, is_trial;

-- Q8. Trial percentage within each plan tier
SELECT
    plan_tier,
    COUNT(*) AS total_subscriptions,
    SUM(CASE WHEN is_trial = TRUE THEN 1 ELSE 0 END) AS trial_subscriptions,
    ROUND(
        100.0 * SUM(CASE WHEN is_trial = TRUE THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS trial_percentage
FROM subscriptions_clean
GROUP BY plan_tier
ORDER BY trial_percentage DESC;

-- Q9. Subscriptions by plan change type
SELECT
    CASE
        WHEN upgrade_flag = TRUE THEN 'Upgrade'
        WHEN downgrade_flag = TRUE THEN 'Downgrade'
        ELSE 'No Change'
    END AS subscription_change,
    COUNT(*) AS subscription_count
FROM subscriptions_clean
GROUP BY subscription_change
ORDER BY subscription_count DESC;

-- Q10. MRR and subscription count by billing frequency
SELECT
    billing_frequency,
    COUNT(*)                  AS subscription_count,
    SUM(mrr_amount)           AS total_mrr,
    ROUND(AVG(mrr_amount), 2) AS avg_mrr
FROM subscriptions_clean
GROUP BY billing_frequency
ORDER BY total_mrr DESC;

-- Q11. Unique accounts per plan tier
SELECT
    plan_tier,
    COUNT(DISTINCT account_id) AS unique_accounts
FROM subscriptions_clean
GROUP BY plan_tier
ORDER BY unique_accounts DESC;

-- Q12. Average subscriptions per account by plan tier
SELECT
    plan_tier,
    ROUND(COUNT(*)::numeric / COUNT(DISTINCT account_id), 2) AS avg_subscriptions_per_account
FROM subscriptions_clean
GROUP BY plan_tier
ORDER BY avg_subscriptions_per_account DESC;


-- =============================================================================
-- SECTION 2 — Account Analysis
-- =============================================================================

-- Q13. Account count by plan tier
SELECT
    plan_tier,
    COUNT(*) AS account_count
FROM accounts_clean
GROUP BY plan_tier
ORDER BY account_count DESC;

-- Q14. Account count by referral source
SELECT
    referral_source,
    COUNT(*) AS account_count
FROM accounts_clean
GROUP BY referral_source
ORDER BY account_count DESC;

-- Q15. MRR by referral source
SELECT
    a.referral_source,
    COUNT(DISTINCT a.account_id)  AS account_count,
    SUM(s.mrr_amount)             AS total_mrr,
    ROUND(AVG(s.mrr_amount), 2)   AS avg_mrr
FROM accounts_clean a
JOIN subscriptions_clean s ON a.account_id = s.account_id
GROUP BY a.referral_source
ORDER BY total_mrr DESC;

-- Q16. Account count by industry
SELECT
    industry,
    COUNT(*) AS account_count
FROM accounts_clean
GROUP BY industry
ORDER BY account_count DESC;

-- Q17. MRR by industry
SELECT
    a.industry,
    COUNT(DISTINCT a.account_id) AS account_count,
    SUM(s.mrr_amount)            AS total_mrr,
    ROUND(AVG(s.mrr_amount), 2)  AS avg_mrr
FROM accounts_clean a
JOIN subscriptions_clean s ON a.account_id = s.account_id
GROUP BY a.industry
ORDER BY total_mrr DESC;


-- =============================================================================
-- SECTION 3 — Churn Analysis
-- =============================================================================

-- Q18. Overall churn rate
SELECT
    COUNT(*) AS total_accounts,
    SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END) AS churned_accounts,
    ROUND(
        100.0 * SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM accounts_clean;

-- Q19. Churn rate by plan tier
SELECT
    plan_tier,
    COUNT(*) AS total_accounts,
    SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END) AS churned_accounts,
    ROUND(
        100.0 * SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM accounts_clean
GROUP BY plan_tier
ORDER BY churn_rate_percentage DESC;

-- Q20. Churn rate by industry
SELECT
    industry,
    COUNT(*) AS total_accounts,
    SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END) AS churned_accounts,
    ROUND(
        100.0 * SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM accounts_clean
GROUP BY industry
ORDER BY churn_rate_percentage DESC;

-- Q21. Churn rate by referral source
SELECT
    referral_source,
    COUNT(*) AS total_accounts,
    SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END) AS churned_accounts,
    ROUND(
        100.0 * SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM accounts_clean
GROUP BY referral_source
ORDER BY churn_rate_percentage DESC;

-- Q22. Trial vs paid churn rate (one row per account — avoids double-counting)
SELECT
    is_trial,
    COUNT(*) AS total_accounts,
    SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END) AS churned_accounts,
    ROUND(
        100.0 * SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM accounts_clean
GROUP BY is_trial
ORDER BY is_trial;

-- Q23. Churn rate by customer size (seats)
SELECT
    CASE
        WHEN seats <= 10 THEN 'Small (1-10)'
        WHEN seats <= 30 THEN 'Medium (11-30)'
        ELSE 'Large (31+)'
    END AS customer_size,
    COUNT(*) AS total_accounts,
    SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END) AS churned_accounts,
    ROUND(
        100.0 * SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM accounts_clean
GROUP BY customer_size
ORDER BY churn_rate_percentage DESC;

-- Q24. Churn rate by auto-renewal status
SELECT
    s.auto_renew_flag,
    COUNT(DISTINCT s.account_id) AS total_accounts,
    COUNT(DISTINCT CASE WHEN a.churn_flag = TRUE THEN s.account_id END) AS churned_accounts,
    ROUND(
        100.0 * COUNT(DISTINCT CASE WHEN a.churn_flag = TRUE THEN s.account_id END)
        / COUNT(DISTINCT s.account_id),
        2
    ) AS churn_rate_percentage
FROM subscriptions_clean s
JOIN accounts_clean a ON s.account_id = a.account_id
GROUP BY s.auto_renew_flag
ORDER BY churn_rate_percentage DESC;

-- Q25. Churn rate by billing frequency
SELECT
    s.billing_frequency,
    COUNT(DISTINCT s.account_id) AS total_accounts,
    COUNT(DISTINCT CASE WHEN a.churn_flag = TRUE THEN s.account_id END) AS churned_accounts,
    ROUND(
        100.0 * COUNT(DISTINCT CASE WHEN a.churn_flag = TRUE THEN s.account_id END)
        / COUNT(DISTINCT s.account_id),
        2
    ) AS churn_rate_percentage
FROM subscriptions_clean s
JOIN accounts_clean a ON s.account_id = a.account_id
GROUP BY s.billing_frequency
ORDER BY churn_rate_percentage DESC;

-- Q26. Churned vs retained MRR
WITH account_mrr AS (
    SELECT account_id, SUM(mrr_amount) AS total_mrr
    FROM subscriptions_clean
    GROUP BY account_id
)
SELECT
    a.churn_flag,
    COUNT(*) AS accounts,
    ROUND(AVG(am.total_mrr)::numeric, 2) AS avg_mrr,
    ROUND(SUM(am.total_mrr)::numeric, 2) AS total_mrr
FROM accounts_clean a
JOIN account_mrr am ON a.account_id = am.account_id
GROUP BY a.churn_flag
ORDER BY a.churn_flag;

-- Q27. Churned MRR by industry
WITH account_mrr AS (
    SELECT account_id, SUM(mrr_amount) AS total_mrr
    FROM subscriptions_clean
    GROUP BY account_id
)
SELECT
    a.industry,
    COUNT(*) AS total_accounts,
    SUM(CASE WHEN a.churn_flag = TRUE THEN 1 ELSE 0 END) AS churned_accounts,
    ROUND(
        100.0 * SUM(CASE WHEN a.churn_flag = TRUE THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate_percentage,
    ROUND(SUM(CASE WHEN a.churn_flag = TRUE THEN am.total_mrr ELSE 0 END)::numeric, 2) AS churned_mrr
FROM accounts_clean a
JOIN account_mrr am ON a.account_id = am.account_id
GROUP BY a.industry
ORDER BY churned_mrr DESC;

-- Q28. Revenue impact by churn reason
WITH account_mrr AS (
    SELECT account_id, SUM(mrr_amount) AS total_mrr
    FROM subscriptions_clean
    GROUP BY account_id
)
SELECT
    ce.reason_code,
    COUNT(DISTINCT ce.account_id)              AS churned_accounts,
    ROUND(SUM(am.total_mrr)::numeric, 2)       AS churned_mrr,
    ROUND(AVG(am.total_mrr)::numeric, 2)       AS avg_mrr_per_churned_account
FROM churn_events_clean ce
JOIN account_mrr am ON ce.account_id = am.account_id
GROUP BY ce.reason_code
ORDER BY churned_mrr DESC;

-- Q29. Churn reasons by industry
SELECT
    a.industry,
    ce.reason_code,
    COUNT(DISTINCT ce.account_id) AS churned_accounts,
    ROUND(
        100.0 * COUNT(DISTINCT ce.account_id)
        / SUM(COUNT(DISTINCT ce.account_id)) OVER (PARTITION BY a.industry),
        2
    ) AS percentage_of_industry_churn
FROM churn_events_clean ce
JOIN accounts_clean a ON ce.account_id = a.account_id
GROUP BY a.industry, ce.reason_code
ORDER BY a.industry, churned_accounts DESC;

-- Q30. Customer tenure vs churn
WITH churn_dates AS (
    SELECT account_id, MIN(churn_date::date) AS churn_date
    FROM churn_events_clean
    GROUP BY account_id
)
SELECT
    CASE WHEN a.churn_flag = TRUE THEN 'Churned' ELSE 'Retained' END AS customer_status,
    COUNT(*) AS total_accounts,
    ROUND(
        AVG(
            CASE
                WHEN a.churn_flag = TRUE THEN cd.churn_date - a.signup_date::date
                ELSE CURRENT_DATE - a.signup_date::date
            END
        )::numeric,
        2
    ) AS avg_tenure_days
FROM accounts_clean a
LEFT JOIN churn_dates cd ON a.account_id = cd.account_id
GROUP BY a.churn_flag
ORDER BY a.churn_flag;

-- Q31. Churn rate by tenure group
SELECT
    CASE
        WHEN customer_tenure_days <= 90  THEN '0-3 months'
        WHEN customer_tenure_days <= 180 THEN '3-6 months'
        WHEN customer_tenure_days <= 365 THEN '6-12 months'
        ELSE '12+ months'
    END AS tenure_group,
    COUNT(*) AS total_accounts,
    SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END) AS churned_accounts,
    ROUND(
        100.0 * SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM account_level_features
GROUP BY tenure_group
ORDER BY churn_rate_percentage DESC;

-- Q32. When during the first year do customers churn?
WITH churn_dates AS (
    SELECT account_id, MIN(churn_date::date) AS churn_date
    FROM churn_events_clean
    GROUP BY account_id
),
churned_customers AS (
    SELECT
        a.account_id,
        cd.churn_date - a.signup_date::date AS tenure_days
    FROM accounts_clean a
    JOIN churn_dates cd ON a.account_id = cd.account_id
    WHERE a.churn_flag = TRUE
)
SELECT
    CASE
        WHEN tenure_days <= 30  THEN '0-30 days'
        WHEN tenure_days <= 90  THEN '31-90 days'
        WHEN tenure_days <= 180 THEN '91-180 days'
        WHEN tenure_days <= 365 THEN '181-365 days'
        ELSE '365+ days'
    END AS churn_timing,
    COUNT(*) AS churned_accounts,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage_of_churn
FROM churned_customers
GROUP BY churn_timing
ORDER BY MIN(tenure_days);

-- Q33. Churn rate by customer size
SELECT
    CASE
        WHEN seats <= 10 THEN 'Small (1-10)'
        WHEN seats <= 30 THEN 'Medium (11-30)'
        ELSE 'Large (31+)'
    END AS customer_size,
    COUNT(*) AS total_accounts,
    SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END) AS churned_accounts,
    ROUND(
        100.0 * SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM accounts_clean
GROUP BY customer_size
ORDER BY MIN(seats);

-- Q34. Churn rate by MRR segment
WITH account_mrr AS (
    SELECT account_id, SUM(mrr_amount) AS total_mrr
    FROM subscriptions_clean
    GROUP BY account_id
)
SELECT
    CASE
        WHEN total_mrr < 10000  THEN 'Low MRR (<10K)'
        WHEN total_mrr < 25000  THEN 'Medium MRR (10K-25K)'
        ELSE 'High MRR (25K+)'
    END AS mrr_segment,
    COUNT(*) AS total_accounts,
    SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END) AS churned_accounts,
    ROUND(
        100.0 * SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM accounts_clean a
JOIN account_mrr am ON a.account_id = am.account_id
GROUP BY mrr_segment
ORDER BY MIN(total_mrr);

-- Q35. Highest-risk segments (industry + referral source)
SELECT
    a.industry,
    a.referral_source,
    COUNT(*) AS total_accounts,
    SUM(CASE WHEN a.churn_flag = TRUE THEN 1 ELSE 0 END) AS churned_accounts,
    ROUND(
        100.0 * SUM(CASE WHEN a.churn_flag = TRUE THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM accounts_clean a
GROUP BY a.industry, a.referral_source
HAVING COUNT(*) >= 5
ORDER BY churn_rate_percentage DESC;

-- Q36. MRR at risk by segment
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
HAVING COUNT(*) >= 10
ORDER BY churned_mrr DESC;

-- Q37. Overall churn and revenue impact summary
WITH account_mrr AS (
    SELECT account_id, SUM(mrr_amount) AS total_mrr
    FROM subscriptions_clean
    GROUP BY account_id
)
SELECT
    COUNT(*) AS total_accounts,
    SUM(CASE WHEN a.churn_flag = TRUE THEN 1 ELSE 0 END) AS churned_accounts,
    ROUND(
        100.0 * SUM(CASE WHEN a.churn_flag = TRUE THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS overall_churn_rate,
    ROUND(SUM(am.total_mrr)::numeric, 2) AS total_mrr,
    ROUND(SUM(CASE WHEN a.churn_flag = TRUE THEN am.total_mrr ELSE 0 END)::numeric, 2) AS churned_mrr,
    ROUND(
        100.0 * SUM(CASE WHEN a.churn_flag = TRUE THEN am.total_mrr ELSE 0 END)
        / SUM(am.total_mrr),
        2
    ) AS percentage_mrr_lost
FROM accounts_clean a
JOIN account_mrr am ON a.account_id = am.account_id;


-- =============================================================================
-- SECTION 4 — Feature Usage Analysis
-- =============================================================================

-- Q38. Average feature usage: churned vs retained customers
SELECT
    a.churn_flag,
    COUNT(DISTINCT a.account_id)       AS accounts,
    ROUND(AVG(fu.usage_count), 2)      AS avg_usage_count,
    ROUND(AVG(fu.usage_duration_secs), 2) AS avg_usage_duration_secs,
    ROUND(AVG(fu.error_count), 2)      AS avg_error_count
FROM accounts_clean a
JOIN subscriptions_clean s  ON a.account_id = s.account_id
JOIN feature_usage_clean fu ON s.subscription_id = fu.subscription_id
GROUP BY a.churn_flag
ORDER BY a.churn_flag;

-- Q39. Total usage per account by churn status
WITH account_usage AS (
    SELECT
        s.account_id,
        SUM(fu.usage_count)          AS total_usage,
        SUM(fu.usage_duration_secs)  AS total_usage_duration,
        SUM(fu.error_count)          AS total_errors
    FROM subscriptions_clean s
    JOIN feature_usage_clean fu ON s.subscription_id = fu.subscription_id
    GROUP BY s.account_id
)
SELECT
    a.churn_flag,
    COUNT(*) AS accounts,
    ROUND(AVG(au.total_usage), 2)          AS avg_total_usage,
    ROUND(AVG(au.total_usage_duration), 2) AS avg_total_usage_duration,
    ROUND(AVG(au.total_errors), 2)         AS avg_total_errors
FROM accounts_clean a
JOIN account_usage au ON a.account_id = au.account_id
GROUP BY a.churn_flag
ORDER BY a.churn_flag;

-- Q40. Features with the largest usage gap between churned and retained
SELECT
    fu.feature_name,
    ROUND(AVG(CASE WHEN a.churn_flag = FALSE THEN fu.usage_count END)::numeric, 2) AS avg_usage_retained,
    ROUND(AVG(CASE WHEN a.churn_flag = TRUE  THEN fu.usage_count END)::numeric, 2) AS avg_usage_churned,
    ROUND(
        (AVG(CASE WHEN a.churn_flag = FALSE THEN fu.usage_count END)
         - AVG(CASE WHEN a.churn_flag = TRUE THEN fu.usage_count END))::numeric,
        2
    ) AS usage_difference
FROM feature_usage_clean fu
JOIN subscriptions_clean s ON fu.subscription_id = s.subscription_id
JOIN accounts_clean a      ON s.account_id = a.account_id
GROUP BY fu.feature_name
ORDER BY usage_difference DESC;

-- Q41. Usage decline before churn (last 30 days vs 31-60 days before churn date)
WITH churned_accounts AS (
    SELECT account_id, churn_date::date AS churn_date
    FROM churn_events_clean
    WHERE is_reactivation = FALSE
),
usage_periods AS (
    SELECT
        ca.account_id,
        CASE
            WHEN fu.usage_date::date >= ca.churn_date - INTERVAL '30 days'
                THEN 'Last 30 Days'
            WHEN fu.usage_date::date >= ca.churn_date - INTERVAL '60 days'
                THEN '31-60 Days Before Churn'
        END AS usage_period,
        fu.usage_count
    FROM churned_accounts ca
    JOIN subscriptions_clean s  ON ca.account_id = s.account_id
    JOIN feature_usage_clean fu ON s.subscription_id = fu.subscription_id
    WHERE fu.usage_date::date BETWEEN ca.churn_date - INTERVAL '60 days' AND ca.churn_date
)
SELECT
    usage_period,
    COUNT(*) AS usage_records,
    ROUND(AVG(usage_count), 2) AS avg_usage_count
FROM usage_periods
WHERE usage_period IS NOT NULL
GROUP BY usage_period
ORDER BY CASE WHEN usage_period = 'Last 30 Days' THEN 1 ELSE 2 END;


-- =============================================================================
-- SECTION 5 — Support Analysis
-- =============================================================================

-- Q42. Support ticket volume: churned vs retained
WITH ticket_counts AS (
    SELECT account_id, COUNT(*) AS ticket_count
    FROM support_tickets_clean
    GROUP BY account_id
)
SELECT
    a.churn_flag,
    COUNT(*) AS accounts,
    ROUND(AVG(COALESCE(tc.ticket_count, 0)), 2) AS avg_tickets_per_account
FROM accounts_clean a
LEFT JOIN ticket_counts tc ON a.account_id = tc.account_id
GROUP BY a.churn_flag
ORDER BY a.churn_flag;

-- Q43. Support experience: churned vs retained
SELECT
    a.churn_flag,
    COUNT(*) AS tickets,
    ROUND(AVG(st.resolution_time_hours)::numeric, 2)       AS avg_resolution_hours,
    ROUND(AVG(st.first_response_time_minutes)::numeric, 2) AS avg_first_response_minutes,
    ROUND(AVG(st.satisfaction_score)::numeric, 2)          AS avg_satisfaction,
    ROUND(
        100.0 * SUM(CASE WHEN st.escalation_flag = TRUE THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS escalation_rate_percentage
FROM support_tickets_clean st
JOIN accounts_clean a ON st.account_id = a.account_id
GROUP BY a.churn_flag
ORDER BY a.churn_flag;

-- Q44. Churn rate for accounts with vs without escalated tickets
WITH account_support AS (
    SELECT
        account_id,
        MAX(CASE WHEN escalation_flag = TRUE THEN 1 ELSE 0 END) AS had_escalation
    FROM support_tickets_clean
    GROUP BY account_id
)
SELECT
    had_escalation,
    COUNT(*) AS total_accounts,
    SUM(CASE WHEN a.churn_flag = TRUE THEN 1 ELSE 0 END) AS churned_accounts,
    ROUND(
        100.0 * SUM(CASE WHEN a.churn_flag = TRUE THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM account_support s
JOIN accounts_clean a ON s.account_id = a.account_id
GROUP BY had_escalation
ORDER BY churn_rate_percentage DESC;

-- Q45. Referral source value: average MRR and churn rate
WITH account_mrr AS (
    SELECT account_id, SUM(mrr_amount) AS total_mrr
    FROM subscriptions_clean
    GROUP BY account_id
)
SELECT
    a.referral_source,
    COUNT(*) AS total_accounts,
    ROUND(AVG(am.total_mrr)::numeric, 2) AS avg_mrr_per_account,
    ROUND(SUM(am.total_mrr)::numeric, 2) AS total_mrr,
    ROUND(
        100.0 * SUM(CASE WHEN a.churn_flag = TRUE THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS churn_rate_percentage
FROM accounts_clean a
JOIN account_mrr am ON a.account_id = am.account_id
GROUP BY a.referral_source
ORDER BY avg_mrr_per_account DESC;

-- ARR at risk summary
SELECT
    COUNT(*) AS total_accounts,
    SUM(CASE WHEN churn_flag = TRUE THEN 1 ELSE 0 END) AS churned_accounts,
    ROUND(SUM(arr_amount)::numeric, 2) AS total_arr,
    ROUND(SUM(CASE WHEN churn_flag = TRUE THEN arr_amount ELSE 0 END)::numeric, 2) AS churned_arr,
    ROUND(
        100.0 * SUM(CASE WHEN churn_flag = TRUE THEN arr_amount ELSE 0 END)
        / SUM(arr_amount),
        2
    ) AS pct_arr_at_risk
FROM account_level_features;

SELECT
    ROUND(SUM(mrr_amount)::numeric, 2)        AS total_mrr,
    ROUND(SUM(mrr_amount * 12)::numeric, 2)   AS mrr_times_12,
    ROUND(SUM(arr_amount)::numeric, 2)        AS total_arr,
    ROUND((SUM(arr_amount) - SUM(mrr_amount)*12)::numeric, 2) AS arr_minus_mrr12
FROM account_level_features;
