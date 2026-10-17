-- Uses accounts_clean's current churn_flag; no account-level churn date is available for a cutoff.
CREATE OR REPLACE VIEW `circleproject-508903.Saas_Subscription_Churn.vw_feature_usage_churn` AS
WITH account_cohort AS (
  SELECT
    account_id,
    churn_flag
  FROM `circleproject-508903.Saas_Subscription_Churn.accounts_clean`
  WHERE account_id IS NOT NULL
    AND churn_flag IS NOT NULL
),
feature_accounts AS (
  SELECT DISTINCT
    usage.feature_name,
    subscription.account_id
  FROM `circleproject-508903.Saas_Subscription_Churn.feature_usage_clean` AS usage
  INNER JOIN `circleproject-508903.Saas_Subscription_Churn.subscriptions_clean` AS subscription
    ON usage.subscription_id = subscription.subscription_id
  INNER JOIN account_cohort AS account
    ON subscription.account_id = account.account_id
  WHERE usage.feature_name IS NOT NULL
),
feature_names AS (
  SELECT DISTINCT feature_name
  FROM feature_accounts
),
feature_population AS (
  SELECT
    feature.feature_name,
    account.account_id,
    account.churn_flag,
    feature_account.account_id IS NOT NULL AS used_feature
  FROM feature_names AS feature
  CROSS JOIN account_cohort AS account
  LEFT JOIN feature_accounts AS feature_account
    ON feature.feature_name = feature_account.feature_name
    AND account.account_id = feature_account.account_id
),
feature_metrics AS (
  SELECT
    feature_name,
    COUNT(DISTINCT IF(used_feature, account_id, NULL)) AS feature_user_count,
    COUNT(DISTINCT IF(used_feature AND churn_flag, account_id, NULL)) AS churned_feature_user_count,
    COUNT(DISTINCT IF(NOT used_feature, account_id, NULL)) AS feature_nonuser_count,
    COUNT(DISTINCT IF(NOT used_feature AND churn_flag, account_id, NULL)) AS churned_feature_nonuser_count
  FROM feature_population
  GROUP BY feature_name
)
SELECT
  feature_name,
  feature_user_count,
  churned_feature_user_count,
  SAFE_DIVIDE(churned_feature_user_count, feature_user_count) AS feature_user_churn_rate,
  feature_nonuser_count,
  churned_feature_nonuser_count,
  SAFE_DIVIDE(churned_feature_nonuser_count, feature_nonuser_count) AS feature_nonuser_churn_rate
FROM feature_metrics
ORDER BY churned_feature_user_count DESC, feature_name;
