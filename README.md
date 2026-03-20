# 📧 Email Engagement & Account Activity Analysis | BigQuery + Looker Studio

## 🔍 Project Overview
This project analyzes account creation and email engagement activity using an e-commerce dataset in **BigQuery**.

The goal was to build a single analytical dataset that helps compare user behavior across countries and account attributes, including:

- country
- send interval
- account verification status
- unsubscribe status

The project combines **account metrics** and **email activity metrics** into one reporting-ready dataset and visualizes the results in **Looker Studio**.

---

## 🎯 Business Goal
The analysis was designed to support decision-making around:

- account growth by country
- email engagement performance
- user segmentation
- identification of high-value markets
- time-based trends in messaging activity

---

## 🛠 Tools & Technologies
- **SQL**
- **Google BigQuery**
- **Looker Studio**
- **Window Functions**
- **CTEs**
- **UNION ALL**
- **Analytical Reporting**

---

## 📊 Dataset Structure
The final dataset was built using data from an e-commerce database and includes the following dimensions:

- `date`
- `country`
- `send_interval`
- `is_verified`
- `is_unsubscribed`

And the following key metrics:

- `account_cnt`
- `sent_msg`
- `open_msg`
- `visit_msg`
- `total_country_account_cnt`
- `total_country_sent_cnt`
- `rank_total_country_account_cnt`
- `rank_total_country_sent_cnt`

---

## ⚙️ What I Did
- Wrote a SQL query in **BigQuery** using multiple **CTEs**
- Calculated account creation metrics and email engagement metrics separately
- Combined both metric groups using **UNION ALL**
- Aggregated results by country, date, and account attributes
- Applied **window functions** to calculate country-level totals and rankings
- Filtered the final output to show only the top countries by account count or sent emails
- Built a **Looker Studio dashboard** to visualize country-level metrics and email activity over time

---

## 📈 Key Insights
- The **United States** had the largest number of created accounts (**12,384**), significantly ahead of other countries.
- **India** ranked second by account count, followed by **Canada**.
- In contrast, **Italy**, **Singapore**, and **Taiwan** ranked highest by total sent messages.
- This suggests that countries with the largest account base do not necessarily generate the highest email activity.
- Sent email activity increased from **November 2020**, peaked around **late December 2020**, and then gradually declined into **February 2021**.

---

## 🧠 What This Project Demonstrates
This project demonstrates my ability to:

- write analytical SQL in BigQuery
- structure logic using CTEs
- combine datasets with different metric logic
- use window functions for ranking and country-level aggregation
- build reporting-ready datasets
- translate raw query results into business insights
- create dashboard visualizations for stakeholder-friendly analysis

---

## 📷 Dashboard
The dashboard was built in **Looker Studio** and includes:
- account count by country
- country ranking by account count
- country ranking by sent messages
- timeline of sent email activity

---

## 🚀 Outcome
This project reflects a practical analytics workflow:
**raw data → SQL transformation → ranked reporting dataset → dashboard visualization → business insight generation**

It was built as part of my transition into data analytics and reflects my ability to work with structured raw data and reporting logic in a business context.
