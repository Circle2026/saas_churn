WITH date_bounds AS (
  SELECT
    DATE_TRUNC(DATE(MIN(churn_date)), MONTH) AS first_month,
    DATE_TRUNC(DATE(MAX(churn_date)), MONTH) AS last_month
  FROM Saas_Subscription_Churn.churn_event_clean
),
month_spine AS (
  SELECT churn_month
  FROM date_bounds,
  UNNEST(GENERATE_DATE_ARRAY(first_month, last_month, INTERVAL 1 MONTH)) AS churn_month
),
monthly_churn AS (
  SELECT
    DATE_TRUNC(DATE(churn_date), MONTH) AS churn_month,
    COUNT(DISTINCT account_id) AS churned_accounts
  FROM Saas_Subscription_Churn.churn_event_clean
  GROUP BY churn_month
),
monthly_metrics AS (
  SELECT
    months.churn_month,
    COUNT(DISTINCT subscriptions.account_id) AS active_accounts_start,
    COALESCE(churn.churned_accounts, 0) AS churned_accounts
  FROM month_spine AS months
  LEFT JOIN monthly_churn AS churn
    ON churn.churn_month = months.churn_month
  LEFT JOIN Saas_Subscription_Churn.subscriptions_clean AS subscriptions
    ON DATE(subscriptions.start_date) <= months.churn_month
    AND (subscriptions.end_date IS NULL OR DATE(subscriptions.end_date) >= months.churn_month)
  GROUP BY months.churn_month, churn.churned_accounts
)
SELECT
  churn_month,
  active_accounts_start,
  churned_accounts,
  ROUND(SAFE_DIVIDE(churned_accounts, active_accounts_start), 2) AS churn_rate
FROM monthly_metrics