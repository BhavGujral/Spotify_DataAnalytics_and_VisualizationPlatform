-- ============================================================================
-- Solutions to 15 PM & Business Analytics Problems (PostgreSQL)
-- File: 03_solutions_advanced_sql.sql
-- Demonstrates: CTEs, Window Functions (RANK, LAG, NTILE, Rolling AVG), Cohort SQL
-- ============================================================================

-- Q1: Music Tracks vs. Podcast Episodes Engagement
SELECT
    content_type,
    COUNT(*) AS total_streams,
    ROUND(SUM(ms_played) / 3600000.0, 1) AS total_listening_hours,
    ROUND(AVG(completion_rate) * 100.0, 1) AS avg_completion_pct,
    ROUND(SUM(CASE WHEN skipped = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS skip_rate_pct
FROM spotify_events
GROUP BY content_type
ORDER BY total_streams DESC;

-- Q2: Free vs. Premium Engagement Gap
SELECT
    subscription_tier,
    COUNT(DISTINCT user_id) AS active_users,
    COUNT(*) AS total_streams,
    ROUND(AVG(completion_rate) * 100.0, 1) AS avg_completion_pct,
    ROUND(SUM(CASE WHEN skipped = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS skip_rate_pct
FROM spotify_events
GROUP BY subscription_tier;

-- Q3: Month-over-Month (MoM) Streaming Growth Using LAG()
WITH monthly_streams AS (
    SELECT
        TO_CHAR(event_date, 'YYYY-MM') AS stream_month,
        COUNT(*) AS total_streams
    FROM spotify_events
    GROUP BY 1
)
SELECT
    stream_month,
    total_streams,
    LAG(total_streams) OVER (ORDER BY stream_month) AS prev_month_streams,
    ROUND(
        (total_streams - LAG(total_streams) OVER (ORDER BY stream_month)) * 100.0
        / NULLIF(LAG(total_streams) OVER (ORDER BY stream_month), 0),
        2
    ) AS mom_growth_pct
FROM monthly_streams
ORDER BY stream_month;

-- Q4: Discovery Surface Performance Ranking
SELECT
    discovery_source,
    COUNT(*) AS streams,
    ROUND(AVG(completion_rate) * 100.0, 1) AS avg_completion_pct,
    ROUND(SUM(CASE WHEN skipped = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS skip_rate_pct,
    RANK() OVER (ORDER BY AVG(completion_rate) DESC) AS quality_rank
FROM spotify_events
GROUP BY discovery_source
ORDER BY quality_rank;

-- Q5: Top Genre per Country Using Window Partitioning
WITH country_genre AS (
    SELECT
        country,
        genre,
        COUNT(*) AS streams,
        RANK() OVER (PARTITION BY country ORDER BY COUNT(*) DESC) AS genre_rank
    FROM spotify_events
    GROUP BY country, genre
)
SELECT country, genre AS top_genre, streams
FROM country_genre
WHERE genre_rank = 1
ORDER BY streams DESC;

-- Q6: Country-Level Premium Mix & Streams per Active User
SELECT
    country,
    COUNT(DISTINCT user_id) AS active_users,
    COUNT(*) AS total_streams,
    ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT user_id), 2) AS streams_per_user,
    ROUND(SUM(CASE WHEN subscription_tier = 'Premium' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS premium_share_pct
FROM spotify_events
GROUP BY country
ORDER BY total_streams DESC;

-- Q7: Multi-Month Retention-Adjacent Stickiness (Users Active in 3+ Months)
WITH user_months AS (
    SELECT
        user_id,
        subscription_tier,
        COUNT(DISTINCT TO_CHAR(event_date, 'YYYY-MM')) AS active_months
    FROM spotify_events
    GROUP BY user_id, subscription_tier
)
SELECT
    subscription_tier,
    COUNT(*) AS total_users,
    SUM(CASE WHEN active_months >= 3 THEN 1 ELSE 0 END) AS sticky_users_3m_plus,
    ROUND(SUM(CASE WHEN active_months >= 3 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS stickiness_pct
FROM user_months
GROUP BY subscription_tier;

-- Q8: Signup Cohort Activity Matrix
WITH cohort_activity AS (
    SELECT
        signup_month,
        TO_CHAR(event_date, 'YYYY-MM') AS active_month,
        COUNT(DISTINCT user_id) AS active_users
    FROM spotify_events
    GROUP BY 1, 2
)
SELECT
    signup_month,
    active_month,
    active_users,
    FIRST_VALUE(active_users) OVER (PARTITION BY signup_month ORDER BY active_month) AS cohort_base_users
FROM cohort_activity
ORDER BY signup_month, active_month;

-- Q9: Algorithmic Discovery (Discover Weekly) vs. Home Feed by Subscription Tier
SELECT
    discovery_source,
    subscription_tier,
    COUNT(*) AS streams,
    ROUND(AVG(completion_rate) * 100.0, 1) AS avg_completion_pct,
    ROUND(SUM(CASE WHEN skipped = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS skip_rate_pct
FROM spotify_events
WHERE discovery_source IN ('Discover Weekly', 'Home Feed', 'Autoplay')
GROUP BY discovery_source, subscription_tier
ORDER BY discovery_source, subscription_tier;

-- Q10: Top 10 Artists & Podcast Shows by Total Listening Hours
SELECT
    artist_name,
    content_type,
    COUNT(*) AS streams,
    ROUND(SUM(ms_played) / 3600000.0, 1) AS total_hours,
    ROUND(AVG(completion_rate) * 100.0, 1) AS avg_completion_pct
FROM spotify_events
GROUP BY artist_name, content_type
ORDER BY total_hours DESC
LIMIT 10;

-- Q11: New Releases (2025-2026) vs. Back Catalog Performance
SELECT
    CASE WHEN release_year >= 2025 THEN 'New Release (2025-2026)' ELSE 'Back Catalog (<=2024)' END AS catalog_segment,
    COUNT(*) AS streams,
    ROUND(AVG(completion_rate) * 100.0, 1) AS avg_completion_pct,
    ROUND(SUM(CASE WHEN skipped = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS skip_rate_pct
FROM spotify_events
GROUP BY 1;

-- Q12: Device Engagement Breakdown (Music vs. Podcasts)
SELECT
    device_type,
    content_type,
    COUNT(*) AS streams,
    ROUND(AVG(completion_rate) * 100.0, 1) AS avg_completion_pct
FROM spotify_events
GROUP BY device_type, content_type
ORDER BY device_type, streams DESC;

-- Q13: Power / Core / Casual Listener Segmentation Using NTILE(3)
WITH user_volume AS (
    SELECT
        user_id,
        COUNT(*) AS total_streams,
        ROUND(AVG(completion_rate) * 100.0, 1) AS avg_completion_pct,
        NTILE(3) OVER (ORDER BY COUNT(*) DESC) AS segment_bucket
    FROM spotify_events
    GROUP BY user_id
)
SELECT
    CASE segment_bucket
        WHEN 1 THEN 'Power Listeners'
        WHEN 2 THEN 'Core Listeners'
        ELSE 'Casual Listeners'
    END AS listener_tier,
    COUNT(*) AS users,
    ROUND(AVG(total_streams), 1) AS avg_streams,
    ROUND(AVG(avg_completion_pct), 1) AS avg_completion_pct
FROM user_volume
GROUP BY segment_bucket
ORDER BY segment_bucket;

-- Q14: Explicit Content Engagement by Age Group
SELECT
    age_group,
    explicit_flag,
    COUNT(*) AS streams,
    ROUND(AVG(completion_rate) * 100.0, 1) AS avg_completion_pct
FROM spotify_events
WHERE content_type = 'Music Track'
GROUP BY age_group, explicit_flag
ORDER BY age_group, explicit_flag;

-- Q15: 3-Month Rolling Average Streams & Skip Rate
WITH monthly_metrics AS (
    SELECT
        TO_CHAR(event_date, 'YYYY-MM') AS stream_month,
        COUNT(*) AS streams,
        ROUND(SUM(CASE WHEN skipped = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS skip_rate_pct
    FROM spotify_events
    GROUP BY 1
)
SELECT
    stream_month,
    streams,
    ROUND(AVG(streams) OVER (ORDER BY stream_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 1) AS rolling_3m_streams,
    skip_rate_pct,
    ROUND(AVG(skip_rate_pct) OVER (ORDER BY stream_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS rolling_3m_skip_pct
FROM monthly_metrics
ORDER BY stream_month;
