WITH industry_counts AS (
  SELECT
    industry,
    COUNT(*) AS total_customers,
    COUNTIF(churn_flag IS TRUE) AS churned_customers,
    COUNTIF(churn_flag IS FALSE) AS active_customers
  FROM `Saas_Subscription_Churn.accounts_clean`
  GROUP BY industry
)
SELECT
  industry,
  total_customers,
  churned_customers,
  active_customers,
  ROUND(SAFE_DIVIDE(churned_customers * 100, total_customers), 2) AS churn_rate
FROM industry_counts
ORDER BY churn_rate DESC
