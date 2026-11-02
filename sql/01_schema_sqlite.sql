-- ==============================================================================
-- Customer & Marketing Analytics Data Warehouse Schema (SQLite & PostgreSQL Compatible)
-- Relational Star Schema for Customer Lifetime Value, RFM, Cohort & Campaign Analytics
-- ==============================================================================

DROP TABLE IF EXISTS fact_campaign_responses;
DROP TABLE IF EXISTS fact_retail_transactions;
DROP TABLE IF EXISTS fact_customer_rfm;
DROP TABLE IF EXISTS dim_marketing_customers;
DROP TABLE IF EXISTS dim_retail_customers;

-- ------------------------------------------------------------------------------
-- 1. DIMENSION TABLE: Retail Customers (Online Retail Universe)
-- ------------------------------------------------------------------------------
CREATE TABLE dim_retail_customers (
    customer_id INTEGER PRIMARY KEY,
    first_purchase_date DATE NOT NULL,
    latest_purchase_date DATE NOT NULL,
    tenure_months INTEGER,
    country TEXT NOT NULL,
    total_orders INTEGER,
    total_spend REAL,
    avg_order_value REAL
);

-- ------------------------------------------------------------------------------
-- 2. FACT TABLE: Retail Transactions (Line-Item Level)
-- ------------------------------------------------------------------------------
CREATE TABLE fact_retail_transactions (
    transaction_id INTEGER PRIMARY KEY AUTOINCREMENT,
    invoice TEXT NOT NULL,
    stock_code TEXT NOT NULL,
    description TEXT,
    quantity INTEGER NOT NULL,
    invoice_date TIMESTAMP NOT NULL,
    price REAL NOT NULL,
    customer_id INTEGER,
    country TEXT NOT NULL,
    line_total REAL NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES dim_retail_customers(customer_id)
);

CREATE INDEX idx_trans_cust ON fact_retail_transactions(customer_id);
CREATE INDEX idx_trans_date ON fact_retail_transactions(invoice_date);

-- ------------------------------------------------------------------------------
-- 3. FACT TABLE: Customer RFM Scores & Segments
-- ------------------------------------------------------------------------------
CREATE TABLE fact_customer_rfm (
    customer_id INTEGER PRIMARY KEY,
    recency_days INTEGER NOT NULL,
    frequency_orders INTEGER NOT NULL,
    monetary_total REAL NOT NULL,
    r_score INTEGER NOT NULL,         -- 1 (Oldest) to 5 (Most Recent)
    f_score INTEGER NOT NULL,         -- 1 (Lowest) to 5 (Most Frequent)
    m_score INTEGER NOT NULL,         -- 1 (Lowest) to 5 (Highest Spend)
    rfm_composite TEXT NOT NULL,      -- e.g. '555', '111'
    rfm_segment TEXT NOT NULL,        -- Champions, Loyal, At-Risk, Lost, etc.
    is_churned_90d INTEGER NOT NULL,  -- 1 if Recency > 90 days
    FOREIGN KEY (customer_id) REFERENCES dim_retail_customers(customer_id)
);

-- ------------------------------------------------------------------------------
-- 4. DIMENSION TABLE: Marketing Campaign Population (Personality & Wealth)
-- ------------------------------------------------------------------------------
CREATE TABLE dim_marketing_customers (
    customer_id INTEGER PRIMARY KEY,
    year_birth INTEGER,
    age INTEGER,
    education TEXT,                   -- Graduation, PhD, Master, Basic, 2n Cycle
    marital_status TEXT,              -- Married, Single, Together, Divorced, Widow
    annual_income REAL,
    kidhome INTEGER,
    teenhome INTEGER,
    customer_enrollment_date DATE,
    recency_days INTEGER,
    total_spend REAL,
    total_purchases INTEGER,
    spend_quartile INTEGER            -- Q1 (Lowest) to Q4 (Highest Spend)
);

-- ------------------------------------------------------------------------------
-- 5. FACT TABLE: Campaign Propensity & Historical Responses
-- ------------------------------------------------------------------------------
CREATE TABLE fact_campaign_responses (
    customer_id INTEGER PRIMARY KEY,
    num_deals_purchases INTEGER,
    num_web_purchases INTEGER,
    num_catalog_purchases INTEGER,
    num_store_purchases INTEGER,
    accepted_cmp1 INTEGER,
    accepted_cmp2 INTEGER,
    accepted_cmp3 INTEGER,
    accepted_cmp4 INTEGER,
    accepted_cmp5 INTEGER,
    historical_accepted_count INTEGER,
    response_latest_campaign INTEGER, -- Target Variable (0 or 1)
    predicted_propensity_rf REAL,
    predicted_propensity_lr REAL,
    FOREIGN KEY (customer_id) REFERENCES dim_marketing_customers(customer_id)
);

