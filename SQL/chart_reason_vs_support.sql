SELECT
    reason_code,
    -- 規模
    COUNT(DISTINCT account_id)                        AS accounts,
    COUNT(*)                                          AS churn_events,
    -- 客服指標（本圖主軸）
    ROUND(AVG(avg_satisfaction_score), 3)             AS avg_satisfaction_score,
    ROUND(AVG(avg_resolution_hours), 2)                AS avg_resolution_hours,
    ROUND(AVG(avg_first_response_minutes), 2)          AS avg_first_response_minutes,
    ROUND(AVG(escalation_count), 3)                    AS avg_escalation_count,
    -- 偏誤檢查欄位（讓分析可信度可被檢驗）
    ROUND(100 * COUNTIF(rating_status = '2_開單但未評分')
          / COUNT(DISTINCT account_id), 2)            AS pct_never_rated_pct,
    ROUND(100 * COUNTIF(rating_status = '1_未開單')
          / COUNT(DISTINCT account_id), 2)            AS pct_no_ticket_pct,
    -- 佔全部流失客戶的比例
    ROUND(100 * COUNT(DISTINCT account_id)
          / SUM(COUNT(DISTINCT account_id)) OVER (), 2) AS pct_of_all_churned
FROM
    `circleproject-508903.Saas_Subscription_Churn.v_churn_reason_with_support`
GROUP BY reason_code
ORDER BY accounts DESC
