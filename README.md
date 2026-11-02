# Customer & Marketing Analytics Intelligence Platform
### RFM Segmentation, 24-Month Cohort Retention, 90-Day Churn Modeling & Campaign Response Prediction

[![Python](https://img.shields.io/badge/Python-3.11%2B-blue?logo=python)](https://python.org)
[![SQL](https://img.shields.io/badge/SQL-PostgreSQL%20%7C%20SQLite-green?logo=postgresql)](https://sqlite.org)
[![Scikit-Learn](https://img.shields.io/badge/Scikit--Learn-ML%20Tournament-orange?logo=scikit-learn)](https://scikit-learn.org)
[![Power BI](https://img.shields.io/badge/Power%20BI-Dashboards-F2C811?logo=powerbi)](https://powerbi.microsoft.com)
[![License](https://img.shields.io/badge/License-MIT-success)](LICENSE)

> **End-to-End Enterprise Customer Intelligence Platform** — Combining **SQL Data Warehousing**, **RFM Quintile Scoring**, **Cohort Lifecycle Survival Analytics**, **Machine Learning Propensity Modeling (ROC-AUC 0.884)**, and **Power BI Dashboards** across 8,000+ empirical customer records.

---

## 📌 Executive Summary (2-Minute Skim)

| Analysis Dimension | Headline Metric / Finding | Strategic Business Impact |
|:---|:---:|:---|
| **Revenue Concentration** | **66.3% of GMV from 22.2% of users** | 962 "Champions" drive the vast majority of revenue; retention must be prioritized over broad acquisition. |
| **RFM Segmentation** | 6 behavioral segments via `NTILE(5)` | 645 "At Risk" accounts (₹7.12 Lakhs historical spend) identified as primary win-back targets. |
| **Cohort Retention** | **71.6% drop-off between Month 0 & 1** | Primary churn cliff occurs immediately after first purchase; Day 7-21 onboarding incentives are crucial. |
| **Predictive Churn ML** | **0.816 ROC-AUC & 90.8% Recall** | Random Forest model captures churn events before account abandonment using activity tenure. |
| **Campaign Response by Spend** | Q4 response (**30.0%**) vs Q1 (**5.5%**) | **5.4x conversion lift** in the highest spend quartile over lower quartiles. |
| **Campaign Propensity ML** | **0.884 ROC-AUC** (Random Forest) | Enables a 25% marketing budget cut while preserving **90.7% of total conversions**. |

---

## 🏢 Business Context & Core Objectives

High-growth consumer businesses, retail platforms, and wealth management services cannot sustain margin expansion through top-of-funnel customer acquisition alone. 

This platform delivers an institutional framework to:
1. **Segment Customers by Value**: Objectively tier customers into Champions, Loyal, At-Risk, and Lost accounts using statistical quintiles.
2. **Forecast Inactivity & Churn**: Deploy reproducible 90-day inactivity thresholds and train chronological machine learning models to detect attrition early.
3. **Optimize Marketing Campaign ROI**: Maximize conversion rates by prioritizing outreach toward high-propensity customer segments.
4. **Track Cohort Retention Curves**: Measure multi-month retention across 24 historical acquisition cohorts.

---

## 🏗️ Architecture & Analytical Workflow

```
Raw Transaction & Marketing Data
                │
                ▼
    ┌───────────────────────┐
    │   Python ETL Pipeline │  (Cleaning, schema validation, line-item totals,
    │     src/pipeline.py   │   RFM scoring, and CLV projection integration)
    └───────────────────────┘
                │
                ▼
    ┌────────────────────────────────────────────────────────┐
    │  Analytical SQLite Data Warehouse (customer_analytics_dw.db)│
    │  Star Schema: Retail Customers, Transactions, RFM & Campaigns│
    └────────────────────────────────────────────────────────┘
                │
    ┌───────────┴─────────────────────────┐
    ▼                                     ▼
┌───────────────────────────────┐   ┌───────────────────────────────┐
│ Production Analytical SQL     │   │ Predictive Machine Learning   │
│  - NTILE(5) RFM Scoring       │   │  - Churn Model: 0.816 ROC-AUC │
│  - 24-Month Cohort Retention  │   │  - Campaign Model: 0.884 ROC-AUC│
│  - Spend Quartile Response Lift│   │  - Logistic Reg vs Random Forest│
└───────────────────────────────┘   └───────────────────────────────┘
                │                                     │
                └──────────────────┬──────────────────┘
                                   ▼
                    ┌───────────────────────────────┐
                    │ Interactive Power BI Suite    │
                    │  - 4 Operational Dashboards   │
                    │  - Customer Segmentation      │
                    │  - Cohort Lifecycle Matrix    │
                    │  - Churn & Campaign Analytics │
                    └───────────────────────────────┘
```

---

## 📊 RFM Segmentation Breakdown (Verified Database Output)

Derived from 4,332 customer accounts in `fact_customer_rfm`:

| RFM Segment | Customer Count | Customer Share (%) | Total Revenue (₹) | Revenue Share (%) | Avg Recency (Days) | Avg Frequency |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|
| **Champions** | 962 | 22.2% | ₹52,78,134 | **66.3%** | 12.9 | 11.0 |
| **Loyal Customers** | 992 | 22.9% | ₹12,33,096 | 15.5% | 34.2 | 3.7 |
| **At Risk** | 645 | 14.9% | ₹7,12,042 | 8.9% | 152.7 | 3.4 |
| **Hibernating / Lost** | 1,062 | 24.5% | ₹4,28,141 | 5.4% | 217.9 | 1.1 |
| **Needs Attention** | 352 | 8.1% | ₹1,66,283 | 2.1% | 53.5 | 1.2 |
| **Recent Promising** | 319 | 7.4% | ₹1,40,845 | 1.8% | 18.6 | 1.2 |
| **Total** | **4,332** | **100.0%** | **₹79,58,541** | **100.0%** | — | — |

---

## 🤖 Machine Learning Model Tournaments

### 1. Chronological Churn Prediction (90-Day Inactivity Boundary)
Evaluated on chronological holdout validation to prevent temporal data leakage:

| Model | ROC-AUC | PR-AUC | Precision | Recall | F1-Score |
|:---|:---:|:---:|:---:|:---:|:---:|
| **Logistic Regression** | 0.7595 | 0.7813 | 0.7218 | 0.7822 | 0.7508 |
| **Random Forest (Champion)** | **0.8163** | **0.8231** | **0.7335** | **0.9086** | **0.8117** |

### 2. Marketing Campaign Propensity Prediction
Evaluated on 2,240 marketing customers with 334 historical responders:

| Model | ROC-AUC | PR-AUC | Precision | Recall | F1-Score |
|:---|:---:|:---:|:---:|:---:|:---:|
| **Logistic Regression** | 0.8723 | 0.5898 | 0.3968 | **0.7463** | 0.5181 |
| **Random Forest (Champion)** | **0.8841** | **0.6232** | **0.5556** | 0.5970 | **0.5755** |

---

## 📈 Power BI Visual Reporting Suite

The project includes 4 publication-quality executive reporting views located in `visuals/`:

| Dashboard View | Focus & Analytical Scope | Visual File |
|:---|:---|:---:|
| **1. Customer Segmentation** | RFM segment distributions, revenue share, average basket sizes | `visuals/01_customer_segmentation.png` |
| **2. Retention & Cohorts** | 24-month cohort retention matrix, customer lifecycle decay | `visuals/02_retention_cohort.png` |
| **3. Churn Analysis** | 90-day inactivity drivers, feature correlations, risk scoring | `visuals/03_churn_analysis.png` |
| **4. Campaign Analytics** | Conversion rates by spend quartile, propensity decile lift | `visuals/04_campaign_analysis.png` |

---

## 📁 Repository Structure

```
Customer_Marketing_Analytics_Intelligence/
├── README.md                                  # Executive summary & technical documentation
├── problem_statement.md                       # Strategic business context
├── requirements.txt                           # Python dependencies
├── data/
│   ├── raw/                                   # Online retail transactions & campaign records
│   └── processed/
│       └── customer_analytics_dw.db           # SQLite Analytical Data Warehouse
├── sql/
│   ├── 01_schema_sqlite.sql                   # Star Schema DDL
│   └── 02_rfm_and_cohort_analysis.sql         # Production analytical queries (NTILE, CTEs, Cohorts)
├── src/
│   └── pipeline.py                            # Automated ETL pipeline & DW loader
├── notebooks/
│   └── customer_marketing_analysis.ipynb      # Complete Jupyter walkthrough
├── visuals/                                   # 4 Power BI dashboard screenshots
└── reports/
    ├── EXECUTIVE_CUSTOMER_ANALYTICS_REPORT.md # Full business findings report
    ├── INTERVIEW_DEFENSE_MASTER_GUIDE.md      # Technical interview Q&A defense cheat-sheet
    └── *.csv                                  # Model tournament metrics and test results
```

---

## 🚀 How to Run the Pipeline

```bash
# 1. Clone or navigate to the project directory
cd D:/Resume/projects/Customer_Marketing_Analytics_Intelligence

# 2. Run the automated data pipeline to build the database
python src/pipeline.py

# 3. Explore the SQL queries in SQLite or your preferred client
sqlite3 data/processed/customer_analytics_dw.db < sql/02_rfm_and_cohort_analysis.sql
```

---

*Authored by **Vivek Kumar** (MSc in Analytics, Tata Institute of Social Sciences). Developed for institutional customer analytics and data-driven marketing portfolio demonstration.*

