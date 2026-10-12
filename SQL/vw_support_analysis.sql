SELECT
    st.ticket_id,
    st.account_id,

    a.country,
    a.industry,
    a.plan_tier,

    a.churn_flag,

    st.priority,
    st.escalation_flag,

    st.satisfaction_score,

    st.resolution_time_hours,

    st.first_response_time_minutes,

    CASE
        WHEN st.satisfaction_score >= 4 THEN 'High Satisfaction'
        WHEN st.satisfaction_score >= 2 THEN 'Medium Satisfaction'
        WHEN st.satisfaction_score IS NULL THEN 'No Feedback'
        ELSE 'Low Satisfaction'
    END AS satisfaction_group,

    CASE
        WHEN st.resolution_time_hours <= 24 THEN 'Within 1 Day'
        WHEN st.resolution_time_hours <= 72 THEN '1-3 Days'
        WHEN st.resolution_time_hours <= 120 THEN '3-5 Days'
        ELSE '5+ Days'
    END AS resolution_bucket

FROM
`circleproject-508903.Saas_Subscription_Churn.support_tickets_clean` st

LEFT JOIN
`circleproject-508903.Saas_Subscription_Churn.accounts_clean` a

ON st.account_id = a.account_id
