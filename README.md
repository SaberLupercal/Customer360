# Project Documentation: Customer 360 - Purchase Behavior Analysis

# OVERVIEW

## 📘 Background & Project Objectives

- To support the Marketing team in driving year-end sales, the Data Analyst team analyzed the existing customer base to provide data and insights for advertising, retention, and re-activation strategies.
- The analysis is based on the **Customer 360 model**, which consolidates customer-related data: personal information, purchasing behavior, transaction history, and brand interactions into a single, comprehensive view.
- Within the scope of this report, the focus is on transaction data, applying the **RFM model** (Recency, Frequency, Monetary). Each of the three metrics is **scored from 1–4 based on quartiles**, then combined to segment customers by value and engagement level, forming the basis for more effective marketing strategies.

## 🚀 Content

Using the payment dataset of a hypothetical business, this report analyzes the purchasing behavior of over 113,000 customers over a 3-month period from June 1, 2022 to August 31, 2022, applying the Customer 360 and RFM models to segment customers and propose suitable marketing strategies.

#### Dataset Summary

- `customer_registered`: Customer membership registration data. Each record represents one membership registration event (`id` as primary key)
- `customer_transaction`: Customer purchase transaction history. Each record represents one purchase (`transaction_id` as primary key)
- `location`: Business branch and location data, including branch code, branch name, and region

#### Schema Overview

#### Schema Description Table

| Table Name | Table Type | Short Description | Primary Key (PK) | Foreign Key (FK) |
| --- | --- | --- | --- | --- |
| `customer_registered` | Dimension | Customer membership registration data | `id` | `location_id` |
| `customer_transaction` | Fact | Purchase transaction history | `transaction_id` | `customer_id` |
| `location` | Dimension | Branch and location data | `id` | — |

#### Key Relationships

- `customer_registered` ←→ `customer_transaction`: 1-N
- `customer_registered` ←→ `location`: N-1

## ⭐ Expected Outcome

Segment the entire customer base using the RFM model into 5 segments (VIP, Loyal, Potential, Occasional, At-risk), then visualize the customer composition and propose suitable retention and re-activation strategies for each segment.

---

# PROJECT IMPLEMENTATION

## PART 1: Customer 360 | RFM

#### Customer 360 Model

**Concept:** Customer 360 is a model that consolidates all customer-related data: personal information, purchase history, transaction behavior, and brand interactions into a comprehensive view of each customer. This enables businesses to segment customers, personalize offers, and build more effective marketing strategies.

**Benefits of Customer 360:**

- **Demographics:** Understand who the customer is through age, gender, region, occupation, etc., to accurately define the target customer profile and build segment-appropriate strategies.
- **Transaction:** Reveals what customers bought, how much, when, and at what value enabling assessment of revenue contribution and optimization of revenue-driving campaigns.
- **Interaction:** Tracks how customers engage with the brand through email, website, app, social media, or customer service, to optimize touchpoints and improve service experience.
- **Behavioral:** Analyzes customer behavior, habits, and interests to predict trends and needs, personalize content, and increase conversion rates.

#### RFM Overview

RFM is a customer analysis model based on three metrics: Recency, Frequency, and Monetary. This model helps businesses segment customers by engagement level and value contribution, forming the basis for more suitable retention, advertising, and re-activation strategies.

| Metric | Meaning |
| --- | --- |
| **Recency** | How recently the customer made their last purchase. The more recent the purchase, the higher the likelihood of return. |
| **Frequency** | How often the customer makes purchases. Higher purchase frequency indicates stronger engagement. |
| **Monetary** | How much the customer has spent. Higher spending value indicates greater revenue contribution. |

**Benefits of the RFM Model:**

1. **Effective customer segmentation**: Divides customers into appropriate segments (VIP, Loyal, Potential, Occasional, At-risk) based on actual transaction behavior.
2. **Marketing cost optimization**: Enables precise targeting, focusing budget on the highest-value customers with the greatest response potential.
3. **Improved customer retention**: Makes it easy to identify at-risk customers early, enabling timely win-back campaigns.
4. **Personalized engagement strategy**: Enables tailoring of messaging, offers, and communication channels to the characteristics and value of each RFM segment.

#### BCG Matrix

The BCG Matrix is a tool that helps businesses classify products based on market share and market growth rate. It divides the portfolio into 4 groups: Question Mark, Star, Dog, and Cash Cow, allowing businesses to determine investment strategy and allocate resources effectively.

---

## PART 2: Data Transformation & Customer Segmentation

### Dataset Description

This analysis uses 2 main tables:

- `customer_registered`: Contains customer membership registration data, each record represents one membership registration event (`id` as primary key)
- `customer_transaction`: Contains customer purchase history, each record represents one purchase (`transaction_id` as primary key)

### Data Quality Assessment

**▶ Table `customer_registered`**

- The primary key has no Null values at all.
- The `locationid` and `branchcode` columns have only 1–2 Null values (out of 100k+ rows) and are not used in the analysis.
- The `stopdate` column has many Null values, indicating customers who are **still active** (contract not yet terminated).

→ **Conclusion:** Data quality is **GOOD**. Can be used directly without cleaning.

**▶ Table `customer_transaction`**

- No columns contain Null values.
- The `gmv` column represents order value but contains many zero values that need to be addressed.

→ **Conclusion:** Identify rows with `gmv = 0` and remove them from the table.

### Data Transformation Steps

- **Tool used:** PostgreSQL (Supabase)
- Data was standardized by keeping only customers in the transaction table whose total revenue is non-zero, and who also exist in the registered table, ensuring that only customers still using the service are included in the analysis. **September 1, 2022** was selected as the reference date for the analysis.

#### Step 1: Calculate R-F-M Metrics

| Metric | Formula |
| --- | --- |
| **Recency** | Days since the customer's last purchase, up to Sep 1, 2022 ÷ contract tenure |
| **Frequency** | Total number of purchases up to Sep 1, 2022 ÷ contract tenure |
| **Monetary** | Total revenue from the customer up to Sep 1, 2022 |

#### Step 2: Apply Quartiles to Score R-F-M

- The dataset is divided into 4 equal parts by 3 quartile points: Q1, Q2, Q3. Each metric is scored from 1–4:
    - From min to Q1 → score 1
    - From Q1 to Q2 → score 2
    - From Q2 to Q3 → score 3
    - From Q3 to max → score 4

⚠️ Note: For F and M: **higher value** → higher score. For R: **lower** value → higher score.

#### Step 3: Customer Segmentation

Based on the BCG matrix concept, customers are divided into 5 segments based on the combination of the 3 R-F-M scores:

| Customer Segment | Behavioral Characteristics | R-F-M Combinations |
| --- | --- | --- |
| 🔴 **At-risk** | Low R (1-2): Hasn't purchased in a long time. Low F and M. | 111, 112, 113, 114, 121, 122, 123, 124, 131, 132, 133, 134, 141, 142, 143, 144 |
| 🟠 **Occasional** | Medium R (2): Purchased a while ago. F and M range from low to medium. | 211, 212, 213, 214, 221, 222, 223, 224, 231, 232, 233, 234, 241, 242, 243, 244 |
| 🟡 **Potential** | High R (3-4): Purchased recently. However, F or M is low. | 311, 312, 313, 314, 321, 331, 341, 411, 412, 413, 414, 421, 431, 441 |
| 🟢 **Loyal** | R, F, M are all fairly high (R≥3, F≥2, M≥2). Purchases recently, frequently, with stable spending. | 322, 323, 324, 332, 342, 422, 423, 424, 432, 442 |
| 💎 **VIP** | R, F, M are all high (>3). Purchases recently, frequently, and spends heavily. | 333, 334, 343, 344, 433, 434, 443, 444 |
