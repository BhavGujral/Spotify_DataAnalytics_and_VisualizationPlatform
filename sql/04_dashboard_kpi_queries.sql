-- ============================================================================
-- Dashboard KPI & Chart Queries (Powers Live Web Dashboard + Tableau/Looker)
-- File: 04_dashboard_kpi_queries.sql
-- ============================================================================

-- KPI Banner: Global Platform Metrics
SELECT
    COUNT(*) AS total_streams,
    COUNT(DISTINCT user_id) AS unique_users,
    ROUND(AVG(completion_rate) * 100.0, 1) AS avg_completion_pct,
    ROUND(SUM(CASE WHEN skipped = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS skip_rate_pct,
    ROUND(SUM(CASE WHEN subscription_tier = 'Premium' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS premium_share_pct
FROM spotify_events;

-- Chart 1: Monthly Streaming & Completion Trend
SELECT TO_CHAR(event_date, 'YYYY-MM') AS month, COUNT(*) AS streams,
       ROUND(AVG(completion_rate) * 100.0, 1) AS avg_completion_pct
FROM spotify_events GROUP BY 1 ORDER BY 1;

-- Chart 2: Discovery Surface Skip Rate & Completion Quality
SELECT discovery_source, COUNT(*) AS streams,
       ROUND(AVG(completion_rate) * 100.0, 1) AS avg_completion_pct,
       ROUND(SUM(CASE WHEN skipped = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS skip_rate_pct
FROM spotify_events GROUP BY 1 ORDER BY skip_rate_pct ASC;

-- Chart 3: Top Genres by Volume & Completion
SELECT genre, content_type, COUNT(*) AS streams,
       ROUND(AVG(completion_rate) * 100.0, 1) AS avg_completion_pct
FROM spotify_events GROUP BY 1, 2 ORDER BY streams DESC;

-- Chart 4: Geographic Distribution & Premium Mix
SELECT country, COUNT(*) AS streams,
       ROUND(SUM(CASE WHEN subscription_tier = 'Premium' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS premium_share_pct
FROM spotify_events GROUP BY 1 ORDER BY streams DESC;
