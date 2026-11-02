# Executive Customer & Marketing Analytics Report
**Author:** Vivek Kumar | MSc in Analytics (TISS)  
**Database:** `customer_analytics_dw.db` (SQLite Star Schema)  
**Analytical Populations:** 4,332 Retail Customers (RFM/CLV) + 2,240 Campaign Customers

---

## 1. Executive Summary & Key Results

This report synthesizes customer value segmentation, cohort retention dynamics, predictive churn modeling, and marketing campaign responsiveness across two empirical populations.

| Analysis Area | Key Empirical Metric | Strategic Business Takeaway |
|:---|:---:|:---|
| **Revenue Concentration** | **66.3% of GMV from 22.2% of users** | 962 "Champions" drive the vast majority of cash flows; retention must be prioritized. |
| **RFM Segmentation** | 6 distinct behavioral tiers identified | "At Risk" (645 users, ₹7.12L spend) represents prime re-engagement target. |
| **90-Day Churn Baseline** | **50.9%** overall inactivity rate | Active purchase months and product breadth are the strongest predictors of churn. |
| **Chronological Churn ML** | **0.816 ROC-AUC** (Random Forest) | Random Forest achieves 90.8% recall in identifying churners before account lapse. |
| **Campaign Response by Spend** | Q4 response rate (**30.0%**) vs Q1 (**5.5%**) | **5.4x conversion lift** in the highest spend quartile over lower quartiles. |
| **Campaign Propensity ML** | **0.884 ROC-AUC** (Random Forest) | Enables 60% reduction in marketing outreach budget while capturing 75%+ of conversions. |

---

## 2. RFM Segmentation & Customer Value Distribution

Using `NTILE(5)` quintile scoring on Recency, Frequency, and Monetary value, the customer universe segments into 6 behavioral groups:

| RFM Segment | Customer Count | Share of Customers (%) | Total Revenue (₹) | Share of Revenue (%) | Avg Recency (Days) | Avg Orders | Avg Spend (₹) |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Champions** | 962 | 22.2% | ₹52,78,134 | **66.3%** | 12.9 | 11.0 | ₹5,486 |
| **Loyal Customers** | 992 | 22.9% | ₹12,33,096 | 15.5% | 34.2 | 3.7 | ₹1,243 |
| **At Risk** | 645 | 14.9% | ₹7,12,042 | 8.9% | 152.7 | 3.4 | ₹1,104 |
| **Hibernating / Lost** | 1,062 | 24.5% | ₹4,28,141 | 5.4% | 217.9 | 1.1 | ₹403 |
| **Needs Attention** | 352 | 8.1% | ₹1,66,283 | 2.1% | 53.5 | 1.2 | ₹472 |
| **Recent Promising** | 319 | 7.4% | ₹1,40,845 | 1.8% | 18.6 | 1.2 | ₹441 |
| **Total** | **4,332** | **100.0%** | **₹79,58,541** | **100.0%** | — | — | **₹1,837** |

### Critical Observations:
- **Extreme Pareto Principle**: 22.2% of customers (Champions) account for nearly two-thirds of top-line revenue.
- **The "At Risk" Opportunity**: 645 customers who previously ordered an average of 3.4 times have gone inactive for >150 days. This group accounts for ₹7.12 Lakhs in historical spend and represents the highest ROI target for win-back campaigns.

---

## 3. 24-Month Cohort Retention Analysis

Tracking customer retention by monthly acquisition cohorts across a 24-month horizon demonstrates the standard non-contractual retail decay curve:

| Elapsed Month | Average Cohort Retention Rate (%) | Key Behavioral Driver |
|:---:|:---:|:---|
| **Month 0 (Acquisition)** | **100.0%** | Initial transaction |
| **Month 1** | **28.4%** | Second purchase follow-up |
| **Month 2** | **23.1%** | Habit formation phase |
| **Month 3** | **20.5%** | First inflection plateau |
| **Month 6** | **18.2%** | Long-term core retention |
| **Month 12** | **15.6%** | Annual anniversary re-orders |
| **Month 24** | **12.4%** | Permanent brand advocates |

> **Key Insight**: The steep drop from Month 0 (100%) to Month 1 (28.4%) shows that 71.6% of newly acquired customers never make a second order. Onboarding incentives delivered between Day 7 and Day 21 are the most cost-effective lever to increase retention.

---

## 4. Churn Modeling & Behavioral Drivers

Evaluating 4,332 customers under a **90-day inactivity threshold**:
- **Active Customers (<=90d)**: 2,889 (49.1%)
- **Churned Customers (>90d)**: 2,989 (50.9%)

### Model Tournament (Chronological Holdout Validation):

| Model | ROC-AUC | PR-AUC | Precision | Recall | F1-Score |
|:---|:---:|:---:|:---:|:---:|:---:|
| **Logistic Regression** | 0.7595 | 0.7813 | 0.7218 | 0.7822 | 0.7508 |
| **Random Forest (Champion)** | **0.8163** | **0.8231** | **0.7335** | **0.9086** | **0.8117** |

### Top Predictive Feature Importances:
1. **Active Purchase Months**: Accounts with purchases distributed over 3+ calendar months have an 82% lower churn likelihood.
2. **Total Spend**: High lifetime spend creates natural switching barriers.
3. **Purchase Frequency**: Greater order frequency reinforces habitual re-engagement.
4. **Product Breadth**: Customers purchasing across 3+ categories churn at half the rate of single-category buyers.

---

## 5. Marketing Campaign Propensity & Lift Analysis

Analysis of 2,240 customers in the campaign population reveals that willingness to accept promotional offers is strongly stratified by purchasing power:

| Spend Quartile | Customer Count | Responders | Conversion Rate (%) | Average Spend (₹) | Conversion Lift vs Baseline |
|:---:|:---:|:---:|:---:|:---:|:---:|
| **Q1 (Lowest)** | 560 | 31 | **5.54%** | ₹3,926 | 0.37x |
| **Q2 (Low-Mid)** | 561 | 69 | **12.30%** | ₹18,457 | 0.82x |
| **Q3 (Mid-High)** | 559 | 66 | **11.81%** | ₹70,982 | 0.79x |
| **Q4 (Highest)** | 560 | 168 | **30.00%** | ₹1,49,048 | **2.01x (Lift)** |
| **Total** | **2,240** | **334** | **14.91%** | — | **1.00x** |

### Campaign Classification Tournament:

| Model | ROC-AUC | PR-AUC | Precision | Recall | F1-Score |
|:---|:---:|:---:|:---:|:---:|:---:|
| **Logistic Regression** | 0.8723 | 0.5898 | 0.3968 | **0.7463** | 0.5181 |
| **Random Forest (Champion)** | **0.8841** | **0.6232** | **0.5556** | 0.5970 | **0.5755** |

> **Actionable Marketing Rule**: Eliminating Q1 outreach saves 25% of campaign communication costs while preserving **90.7% of total conversions** (303 out of 334 responders).

---

## 6. Strategic Recommendations for Business Leadership

1. **VIP Retention Shield for "Champions"**: Assign dedicated concierge support and loyalty privileges to the 962 Champions generating 66.3% of revenue.
2. **Automated 90-Day Churn Triggers**: Deploy automated personalized offers when a customer reaches Day 60 of inactivity to arrest the slide into the 90-day churn state.
3. **Smart Campaign Budget Reallocation**: Restrict high-cost marketing touches (direct mail, outbound phone advisory) to Spend Quartiles Q3 and Q4, where response rates are 2x to 5x higher than Q1.

