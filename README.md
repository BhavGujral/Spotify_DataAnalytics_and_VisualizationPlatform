# Spotify User Engagement & Content Analytics Platform

An end-to-end **SQL Data Analytics & Interactive Visualization Platform** analyzing **10,000 streaming events** across **1,793 active users** and **8 global markets** (`Nov 2025 – Oct 2026`). Built to surface retention-adjacent behavior, algorithmic discovery quality, and Free-to-Premium monetization opportunities for product leadership.

- **Live Interactive Dashboard:** `[[Paste your GitHub Pages URL here after Step 3]](https://spotifydataanalyticsandvisualizatio.vercel.app/)`
- **Tech Stack:** PostgreSQL (CTEs, Window Functions, Cohort SQL), Interactive Web BI Dashboard (HTML/CSS/JS SVG), Tableau / Looker Studio Ready CSVs

---

## Key Executive Metrics (Dataset Baseline)

| Metric | Verified Value | Product Interpretation |
| :--- | :---: | :--- |
| **Total Streams Analyzed** | **10,000** | 1,793 unique users · 1,099.9 listening hours |
| **Average Completion Rate** | **72.3%** | Strong overall session satisfaction across Music & Podcasts |
| **Overall Skip Rate** | **21.6%** | Primary dissatisfaction proxy across discovery surfaces |
| **Premium Stream Share** | **54.8%** | Major regional spread: 43.3% (India) vs. 65.6% (UK) |

---

## Repository Structure

```text
Spotify-Data-Analytics-and-Visualization-Platform/
├── index.html                           # Live interactive dashboard (GitHub Pages ready)
├── README.md                            # Project documentation & verified PM findings
├── DEPLOYMENT_AND_RESUME_GUIDE.txt      # Beginner step-by-step GitHub + Live upload guide
├── data/
│   ├── spotify_listening_events.csv     # 10,000-record listening & engagement dataset
│   └── tableau_looker_exports/          # 6 pre-aggregated CSVs for Tableau / Looker Studio
└── sql/
    ├── 01_schema.sql                    # PostgreSQL table schema & indexes
    ├── 02_business_problems.sql         # 15 structured PM & business analytics questions
    ├── 03_solutions_advanced_sql.sql    # Advanced SQL solutions (CTEs, RANK, LAG, NTILE)
    └── 04_dashboard_kpi_queries.sql     # KPI & chart aggregation queries
```

---

## Top 3 Product Findings

1. **Home Feed Skip Rates Are Nearly 2x Discover Weekly:**
   - **Discover Weekly** achieves a **17.8% skip rate** (**74.7% completion**), whereas **Home Feed** suffers a **34.6% skip rate** (**63.8% completion**). Re-ranking Home Feed cards using collaborative filtering and recent skip penalties is the highest-leverage retention opportunity.
2. **Geographic Monetization Gap (India vs. Mature Markets):**
   - **India** leads streaming volume (**2,551 streams**, 25.5% share) but has a **43.3% Premium mix**, compared to **65.6% in the UK** and **65.4% in Germany**. Localized micro-subscriptions and UPI autopay trials can unlock substantial ARPU lift.
3. **High-Completion Retention Anchors:**
   - **User Library** (**77.0% completion**, **14.1% skip rate**), **Smart Speaker** sessions, and **Podcast Episodes** anchor low-skip listening habits, creating ideal surfaces for cross-format recommendations.

---

## SQL Techniques Demonstrated (`sql/03_solutions_advanced_sql.sql`)

- **CTEs (`WITH`)** for multi-step funnel, cohort, and user-level stickiness calculations
- **Window Functions:** `RANK() OVER (PARTITION BY country)`, `LAG()` for Month-over-Month growth, `FIRST_VALUE()` for signup cohorts, `NTILE(3)` for Power/Core/Casual listener segmentation, and `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW` for 3-month rolling averages
- **Conditional Aggregations (`CASE WHEN`)** for skip rates, Premium mix, and catalog recency splits

---

## How to Run Locally

1. **Preview the Dashboard:** Double-click `index.html` in any web browser (works 100% offline with zero external dependencies).
2. **Run the SQL Scripts in PostgreSQL:**
   ```bash
   psql -d your_database -f sql/01_schema.sql
   psql -d your_database -c "\copy spotify_events FROM 'data/spotify_listening_events.csv' WITH (FORMAT csv, HEADER true);"
   psql -d your_database -f sql/03_solutions_advanced_sql.sql
   ```
