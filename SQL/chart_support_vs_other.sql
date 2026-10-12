SELECT
    CASE WHEN is_support_reason = 1
         THEN '1_自述因客服流失'
         ELSE '2_其他原因流失'
    END                                                AS customer_stated_reason,
    COUNT(DISTINCT account_id)                         AS accounts,
    ROUND(AVG(avg_satisfaction_score), 3)              AS avg_satisfaction_score,
    ROUND(AVG(avg_resolution_hours), 2)                 AS avg_resolution_hours,
    ROUND(AVG(avg_first_response_minutes), 2)           AS avg_first_response_minutes,
    ROUND(AVG(escalation_count), 3)                     AS avg_escalation_count,
    ROUND(AVG(urgent_count), 3)                         AS avg_urgent_count,
    ROUND(100 * COUNTIF(rating_status = '2_開單但未評分')
          / COUNT(DISTINCT account_id), 2)             AS pct_never_rated_pct
FROM
    `circleproject-508903.Saas_Subscription_Churn.v_churn_reason_with_support`
GROUP BY is_support_reason
ORDER BY is_support_reason DESC
