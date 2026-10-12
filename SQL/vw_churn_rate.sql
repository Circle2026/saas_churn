SELECT
  COUNT(DISTINCT account_id) AS total_accounts,
  COUNT(DISTINCT IF(churn_flag, account_id, NULL)) AS churned_accounts,
  ROUND(SAFE_DIVIDE(
    COUNT(DISTINCT IF(churn_flag, account_id, NULL)),
    COUNT(DISTINCT account_id)
  ), 2) AS churn_rate,
  ROUND(100 * SAFE_DIVIDE(
    COUNT(DISTINCT IF(churn_flag, account_id, NULL)),
    COUNT(DISTINCT account_id)
  ), 2) AS churn_rate_percent
FROM Saas_Subscription_Churn.accounts_clean
