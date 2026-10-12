SELECT
    reason_code,
    COUNT(DISTINCT account_id)                        AS accounts,
    COUNT(*)                                          AS churn_events,
    ROUND(100 * COUNT(DISTINCT account_id)
          / SUM(COUNT(DISTINCT account_id)) OVER (), 2) AS pct_of_all_churned,
    COUNTIF(is_reactivation)                          AS reactivation_events,
    ROUND(100 * COUNTIF(is_reactivation) / COUNT(*), 2) AS pct_reactivation,
    ROUND(AVG(refund_amount_usd), 2)                  AS avg_refund_usd
FROM
    `circleproject-508903.Saas_Subscription_Churn.v_churn_reason_with_support`
GROUP BY reason_code
ORDER BY accounts DESC