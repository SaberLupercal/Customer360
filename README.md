# 📊 Customer 360 & RFM Customer Segmentation Analysis

> A comprehensive data analysis pipeline utilizing Customer 360 and RFM modeling to identify high-value customer segments and drive data-backed year-end marketing strategies.

---

## 📘 1. Background & Business Objectives
* **Objective:** Empower the marketing team to boost year-end revenue by analyzing existing customer behavior to tailor retention, targeted advertising, and re-activation strategies.
* **Core Frameworks:** 
  * **Customer 360:** Consolidates comprehensive customer profiles, including demographic details, transaction history, and purchasing behaviors into a unified view.
  * **RFM Model:** Scores customers across three critical dimensions: *Recency* (how recently they purchased), *Frequency* (how often they purchase), and *Monetary* (how much they spend), mapped on a 1–4 scale using quartile distribution.

---

## 🛠️ 2. Dataset & Data Architecture
The analysis is built upon a transactional dataset comprising over **113,000 customers** across a 3-month operational window (June 1, 2022 – August 31, 2022), structured into 3 core tables:
1. `customer_registered` (Dimension): Customer registration details (`id` as Primary Key).
2. `customer_transaction` (Fact): Transaction and purchase history (`transaction_id` as Primary Key).
3. `location` (Dimension): Branch and regional business data (`id` as Primary Key).

* **Key Relationships:**
  * `customer_registered` ↔ `customer_transaction`: One-to-Many (1 customer has multiple transactions).
  * `customer_registered` ↔ `location`: Many-to-One.

---

## ⚙️ 3. Data Transformation & Processing Pipeline
* **Environment:** PostgreSQL (executed via Supabase).
* **Data Cleaning & Preparation:**
  * Cleaned data quality anomalies by filtering out records with `gmv = 0` in the transaction table.
  * Ensured data integrity by matching active transactions with registered customer profiles, setting the baseline snapshot date to `September 1, 2022`.
  * Computed Recency, Frequency, and Monetary values and derived segmented scores using quartile boundaries (Q1, Q2, Q3).

---

## 🎯 4. Customer Segmentation Insights
Based on combined RFM score distributions, customers are categorized into **5 strategic segments**:
* 💎 **VIP (R > 3, F > 3, M > 3):** High-value, frequent shoppers who purchased recently.
* 🟢 **Loyal (R ≥ 3, F ≥ 2, M ≥ 2):** Consistent and reliable repeat customers.
* 🟡 **Potential (R 3–4, low F/M):** New or recent customers with growth potential.
* 🟠 **Occasional (R = 2):** Periodic buyers with low-to-moderate spending patterns.
* 🔴 **At-risk (R = 1–2, low F/M):** Dormant customers exhibiting a high churn risk.
