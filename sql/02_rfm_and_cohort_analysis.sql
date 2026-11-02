-- ==============================================================================
-- Production Customer & Marketing Analytics SQL Queries
-- Demonstrating: NTILE(5) RFM Scoring, Cohort Retention Curves, 90-day Churn Rate,
-- Campaign Response Lift by Spend Quartiles, and Customer Lifetime Value (CLV).
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- QUERY 1: RFM Scoring via NTILE(5) Window Functions
-- Business Purpose: Segment 5,878 customer accounts by Recency, Frequency & Monetary value.
-- ------------------------------------------------------------------------------
WITH customer_base AS (
    SELECT 
        customer_id,
        CAST(julianday('2011-12-09') - julianday(MAX(invoice_date)) AS INT) AS recency_days,
        COUNT(DISTINCT invoice) AS frequency_orders,
        ROUND(SUM(line_total), 2) AS monetary_total
    FROM fact_retail_transactions
    WHERE customer_id IS NOT NULL AND line_total > 0
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT 
        customer_id,
        recency_days,
        frequency_orders,
        monetary_total,
        -- Higher recency days = older purchase = lower score (1 to 5)
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency_orders ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary_total ASC) AS m_score
    FROM customer_base
)
SELECT 
    customer_id,
    recency_days,
    frequency_orders,
    monetary_total,
    r_score,
    f_score,
    m_score,
    (r_score || f_score || m_score) AS rfm_composite,
    CASE 
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customers'
        WHEN r_score >= 4 AND f_score <= 2 THEN 'Recent Customers'
        WHEN r_score <= 2 AND f_score >= 3 AND m_score >= 3 THEN 'High Value At Risk'
        WHEN r_score <= 2 AND f_score >= 2 THEN 'At Risk'
        WHEN r_score <= 2 AND f_score = 1 THEN 'Lost Customers'
        ELSE 'Potential Loyalists'
    END AS rfm_segment,
    CASE WHEN recency_days > 90 THEN 1 ELSE 0 END AS is_churned_90d
FROM rfm_scores
ORDER BY monetary_total DESC
LIMIT 20;


-- ------------------------------------------------------------------------------
-- QUERY 2: RFM Segment Summary (Headcount, Total Revenue, Average Basket)
-- Business Purpose: Identify customer concentration and revenue contribution per tier.
-- ------------------------------------------------------------------------------
SELECT 
    rfm_segment,
    COUNT(*) AS total_customers,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fact_customer_rfm), 2) AS customer_share_pct,
    ROUND(SUM(monetary_total), 2) AS total_revenue,
    ROUND(SUM(monetary_total) * 100.0 / (SELECT SUM(monetary_total) FROM fact_customer_rfm), 2) AS revenue_share_pct,
    ROUND(AVG(recency_days), 1) AS avg_recency_days,
    ROUND(AVG(frequency_orders), 1) AS avg_orders,
    ROUND(AVG(monetary_total), 2) AS avg_customer_value
FROM fact_customer_rfm
GROUP BY rfm_segment
ORDER BY total_revenue DESC;


-- ------------------------------------------------------------------------------
-- QUERY 3: 24-Month Cohort Retention Lifecycle Matrix
-- Business Purpose: Track percentage of cohort returning to purchase across elapsed months.
-- ------------------------------------------------------------------------------
WITH first_purchase AS (
    SELECT 
        customer_id,
        strftime('%Y-%m', MIN(invoice_date)) AS cohort_month
    FROM fact_retail_transactions
    WHERE customer_id IS NOT NULL AND line_total > 0
    GROUP BY customer_id
),
monthly_orders AS (
    SELECT 
        t.customer_id,
        fp.cohort_month,
        strftime('%Y-%m', t.invoice_date) AS order_month,
        (CAST(strftime('%Y', t.invoice_date) AS INT) - CAST(substr(fp.cohort_month, 1, 4) AS INT)) * 12 +
        (CAST(strftime('%m', t.invoice_date) AS INT) - CAST(substr(fp.cohort_month, 6, 2) AS INT)) AS month_number
    FROM fact_retail_transactions t
    INNER JOIN first_purchase fp ON t.customer_id = fp.customer_id
    WHERE t.line_total > 0
    GROUP BY t.customer_id, fp.cohort_month, order_month, month_number
),
cohort_sizes AS (
    SELECT 
        cohort_month, 
        COUNT(DISTINCT customer_id) AS cohort_size
    FROM first_purchase
    GROUP BY cohort_month
)
SELECT 
    mo.cohort_month,
    cs.cohort_size,
    mo.month_number,
    COUNT(DISTINCT mo.customer_id) AS active_customers,
    ROUND(COUNT(DISTINCT mo.customer_id) * 100.0 / cs.cohort_size, 2) AS retention_rate_pct
FROM monthly_orders mo
INNER JOIN cohort_sizes cs ON mo.cohort_month = cs.cohort_month
WHERE mo.month_number BETWEEN 0 AND 12
GROUP BY mo.cohort_month, cs.cohort_size, mo.month_number
ORDER BY mo.cohort_month, mo.month_number;


-- ------------------------------------------------------------------------------
-- QUERY 4: 90-Day Churn Behavioral Divergence
-- Business Purpose: Compare active vs churned behavioral profiles to inform retention triggers.
-- ------------------------------------------------------------------------------
SELECT 
    CASE WHEN is_churned_90d = 1 THEN 'Churned (>90d inactive)' ELSE 'Active (<=90d active)' END AS status,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fact_customer_rfm), 2) AS customer_pct,
    ROUND(AVG(monetary_total), 2) AS avg_spend,
    ROUND(AVG(frequency_orders), 2) AS avg_order_count,
    ROUND(AVG(recency_days), 1) AS avg_recency_days
FROM fact_customer_rfm
GROUP BY is_churned_90d;


-- ------------------------------------------------------------------------------
-- QUERY 5: Marketing Campaign Response Lift across Spend Quartiles
-- Business Purpose: Prove that customer spend quartile is a primary driver of marketing conversion.
-- ------------------------------------------------------------------------------
SELECT 
    c.spend_quartile,
    COUNT(c.customer_id) AS total_customers,
    SUM(r.response_latest_campaign) AS total_responders,
    ROUND(SUM(r.response_latest_campaign) * 100.0 / COUNT(c.customer_id), 2) AS response_rate_pct,
    ROUND(AVG(c.total_spend), 2) AS avg_customer_spend,
    ROUND(AVG(c.annual_income), 2) AS avg_annual_income,
    ROUND(
        (SUM(r.response_latest_campaign) * 100.0 / COUNT(c.customer_id)) / 
        (SELECT AVG(response_latest_campaign) * 100.0 FROM fact_campaign_responses), 2
    ) AS conversion_lift_factor
FROM dim_marketing_customers c
INNER JOIN fact_campaign_responses r ON c.customer_id = r.customer_id
GROUP BY c.spend_quartile
ORDER BY c.spend_quartile;

