# 📊 User Funnel & KPI Performance Analysis

> Analyzed 4,715 user activity records to construct end-to-end product conversion funnels and calculate key performance metrics across 5 stages using SQL.

![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat)
![Last Updated](https://img.shields.io/badge/Last%20Updated-March%202026-blue?style=flat)
![SQL](https://img.shields.io/badge/SQL-MySQL-blue?style=flat&logo=mysql)
![Excel](https://img.shields.io/badge/Excel-Data%20Source-green?style=flat&logo=microsoftexcel)
![HTML](https://img.shields.io/badge/HTML-Chart.js-orange?style=flat&logo=html5)

---

##  Project Overview

| Detail | Info |
|--------|------|
| **Dataset** | `user_kpi_data.xlsx` |
| **Records** | 4,715 events |
| **Users** | 1,800 unique users |
| **Period** | January – March 2024 |
| **Products** | 10 (P1 – P10) |
| **Funnel Stages** | 5 (Visit → Signup → Add to Cart → Checkout → Purchase) |

---

## 📈 Key Findings

### 🔻 Funnel Drop-off

| Stage | Users | Drop-off |
|-------|-------|----------|
| Visit | 1,800 | — |
| Signup | 1,441 | ↓ 19.9% |
| Add to Cart | 1,134 | ↓ 21.3% |
| Checkout | 828 | ↓ **27.0% ⚠️ Highest** |
| Purchase | 630 | ↓ 23.9% |

> **Key Insight:** Biggest drop-off at **Add to Cart → Checkout (27.0%)** — primary area for optimization.

### 🎯 Conversion Rates

| Step | Rate |
|------|------|
| Visit → Signup | 80.1% |
| Signup → Add to Cart | 78.7% ✅ Best |
| Add to Cart → Checkout | 73.0% ⚠️ Lowest |
| Checkout → Purchase | 76.1% |
| **Overall** | **35.0%** |

###  Top Products
P1 (498) · P2 (482) · P3 (476) · P4 (473) · P5 (470)

---

## 🗃️ SQL Scripts — 8 Sections

1. **Database & Table Setup** — schema creation
2. **Data Exploration** — record counts, date range, stage distribution
3. **Funnel Analysis** — users per stage, drop-off %, conversion rates
4. **KPI Metrics** — session duration, page views, returning users
5. **Product Performance** — interactions and conversion per product
6. **Drop-off Insights** — by device, region, and stage
7. **Time-Based Analysis** — daily, weekly, monthly trends
8. **KPI Summary** — single query with all key metrics

---

## 📁 Repository Structure

```
User-Funnel-KPI-Analysis/
│
├── 📄 README.md
├── 📊 user_kpi_data.xlsx              ← Raw dataset (4,715 records)
├── 🗃️ kpi_analysis_queries.sql        ← All SQL scripts (8 sections)
└── 🌐 kpi_dashboard.html              ← Interactive HTML dashboard
```

---


##  Author

**Gauri Sharan** 
