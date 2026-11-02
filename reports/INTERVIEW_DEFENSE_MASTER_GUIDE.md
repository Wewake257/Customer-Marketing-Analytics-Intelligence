# Senior Business Analyst Interview Defense Master Guide
## Project: Customer & Marketing Analytics (RFM, Cohort Retention & CLV)
**Author:** Vivek Kumar | MSc in Analytics (TISS)  
**Target Roles:** Junior Business Analyst / Marketing Data Analyst / Growth & Retention Analyst

---

## 1. 60-Second Technical Pitch

> *"In this project, I built an end-to-end Customer & Marketing Analytics intelligence platform using SQL, Python, Scikit-learn, and Power BI across two empirical datasets totaling 8,000+ customer records.*
> 
> *Key deliverables include: (1) An RFM segmentation engine in SQL using `NTILE(5)` quintile scoring that uncovered that 22.2% of users ('Champions') drive 66.3% of total revenue; (2) A 24-month cohort retention matrix identifying a steep 71.6% drop-off between initial purchase and Month 1; (3) A chronological churn prediction model achieving 0.816 ROC-AUC and 90.8% recall using Random Forest; and (4) A marketing campaign propensity model achieving 0.884 ROC-AUC, demonstrating a 5.4x conversion lift in the highest spend quartile. This allowed us to propose a budget reallocation strategy that reduces marketing communication spend by 25% while protecting 91% of conversions."*

---

## 2. Core Interview Questions & Bulletproof Answers

### Q1: "How did you define churn in a non-contractual setting like e-commerce or retail?"
**Your Answer:**
- *"In a contractual setting (like Netflix or SaaS), churn is explicit when a user cancels their subscription.*
- *In a non-contractual business, churn must be inferred from inactivity.*
- *I implemented a **reproducible 90-day inactivity threshold** from the dataset observation cutoff date. A customer with no transactions in the preceding 90 days was labeled churned (`is_churned_90d = 1`).*
- *To ensure this wasn't arbitrary, I conducted statistical testing on inter-purchase time distributions, confirming that 85%+ of repeat purchases occur within 60 days, making 90 days a statistically sound churn boundary."*

---

### Q2: "Why did you use chronological validation instead of random train/test split for churn prediction?"
**Your Answer:**
- *"Random k-fold cross-validation causes severe **temporal data leakage** in churn prediction. If you train on future transactions to predict past behavior, the model learns lookahead patterns that are impossible in production.*
- *Instead, I implemented **chronological holdout validation**: I established an observation cut-off point (e.g. Month 18), trained the model exclusively on customer behavioral features leading up to that date, and evaluated predictions on churn events that occurred in the subsequent 6-month holdout window.*
- *This mirrors real-world deployment where the marketing team only has access to historical data at inference time."*

---

### Q3: "Explain how you performed RFM scoring in SQL using `NTILE(5)`."
**Your Answer:**
- *"I used Common Table Expressions (CTEs) in SQL:*
  1. *`customer_base`: Computed aggregate Recency (days since latest order), Frequency (distinct invoice count), and Monetary (sum of line totals).*
  2. *`rfm_scores`: Applied `NTILE(5) OVER ()` across each metric:*
     - *For Recency: `NTILE(5) OVER (ORDER BY recency_days DESC)` so the most recent buyers receive a score of 5.*
     - *For Frequency and Monetary: `NTILE(5) OVER (ORDER BY metric ASC)` so highest volume/spend receive a score of 5.*
  3. *Concatenated the scores into an RFM composite (`555`, `111`) and mapped them via `CASE WHEN` into standard actionable segments: Champions, Loyal Customers, At Risk, and Hibernating/Lost.*
- *Using quintiles (`NTILE(5)`) ensures an objective, data-driven 20% distribution across each axis without relying on hardcoded currency amounts."*

---

### Q4: "How does customer spend quartile correlate with marketing campaign response?"
**Your Answer:**
- *"In the campaign analysis dataset of 2,240 customers, the baseline overall campaign conversion rate was **14.91%**.*
- *When segmenting customers into spend quartiles (Q1 lowest to Q4 highest):*
  - *Q1 (Spend < ₹3,900): **5.54% conversion rate** (0.37x baseline).*
  - *Q2 & Q3: ~12.0% conversion rate.*
  - *Q4 (Spend > ₹1,49,000): **30.00% conversion rate** (2.01x baseline / 5.4x higher than Q1).*
- **Business Implication**: *Promotional campaigns should not be blasted uniformly. Eliminating Q1 from expensive marketing channels (direct mail, tele-calling) saves 25% of the campaign budget while retaining 90.7% of all conversions."*

---

### Q5: "Between Logistic Regression and Random Forest, which model did you choose and why?"
**Your Answer:**
- *"For both tasks, I evaluated Logistic Regression and Random Forest:*
  - *For **Campaign Response**: Random Forest achieved **0.884 ROC-AUC** and **0.623 PR-AUC** vs 0.872 / 0.589 for Logistic Regression.*
  - *For **Churn Prediction**: Random Forest achieved **0.816 ROC-AUC** with an exceptional **90.86% Recall**.*
- *Because the financial cost of missing a churner or high-value campaign responder (False Negative) is significantly higher than an unnecessary notification (False Positive), I prioritized **Recall and PR-AUC** over raw Accuracy.*
- *Random Forest captured non-linear interaction terms between Recency and Spend that linear logistic regression failed to model."*

---

### Q6: "How did you calculate Customer Lifetime Value (CLV)?"
**Your Answer:**
- *"I calculated both historical empirical CLV and probabilistic 1-year / 3-year forward CLV:*
  $$\text{CLV} = \text{Average Order Value (AOV)} \times \text{Purchase Frequency} \times \text{Gross Margin} \times \text{Customer Lifespan}$$
- *For forward projections, I used customer survival probability ($P(\text{Alive})$) based on recency and tenure, discounting future revenues at a 10% annual rate.*
- *This enabled tiering customers into 4 CLV Tiers: Tier 1 VIP (>₹10,000), Tier 2 High, Tier 3 Medium, and Tier 4 Low."*

