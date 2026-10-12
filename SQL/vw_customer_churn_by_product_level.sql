WITH plan_counts AS (
  SELECT
    plan_tier,
    COUNT(*) AS total_customers,
    COUNTIF(churn_flag IS TRUE) AS churned_customers,
    COUNTIF(churn_flag IS FALSE) AS active_customers
  FROM `Saas_Subscription_Churn.accounts_clean`
  GROUP BY plan_tier
),
plan_rates AS (
  SELECT
    plan_tier,
    total_customers,
    churned_customers,
    active_customers,
    ROUND(SAFE_DIVIDE(churned_customers * 100, total_customers), 2) AS churn_rate
  FROM plan_counts
)
SELECT
  plan_tier,
  total_customers,
  churned_customers,
  active_customers,
  churn_rate,
  ROUND(churn_rate, 2) AS churn_float,
  SUM(total_customers) OVER () AS product_amount,
  ROUND(
    SAFE_DIVIDE(total_customers, SUM(total_customers) OVER ()) * 100,
    2
  ) AS product_share_rate,
  SUM(churned_customers) OVER () AS total_churned_amount,
  ROUND(
    SAFE_DIVIDE(churned_customers, SUM(churned_customers) OVER ()) * 100,
    2
  ) AS churn_contribution_rate
FROM plan_rates
ORDER BY churn_rate DESC
