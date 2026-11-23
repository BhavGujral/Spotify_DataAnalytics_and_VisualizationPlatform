-- ============================================================================
-- Spotify User Engagement & Content Analytics Platform
-- File: 01_schema.sql (PostgreSQL)
-- ============================================================================

DROP TABLE IF EXISTS spotify_events;

CREATE TABLE spotify_events (
    event_id          VARCHAR(15) PRIMARY KEY,
    user_id           VARCHAR(15) NOT NULL,
    subscription_tier VARCHAR(15) NOT NULL,   -- 'Premium' or 'Free'
    country           VARCHAR(50) NOT NULL,
    age_group         VARCHAR(10) NOT NULL,
    signup_month      VARCHAR(7)  NOT NULL,   -- YYYY-MM
    event_date        DATE        NOT NULL,
    track_title       VARCHAR(150) NOT NULL,
    artist_name       VARCHAR(100) NOT NULL,
    genre             VARCHAR(60) NOT NULL,
    content_type      VARCHAR(30) NOT NULL,   -- 'Music Track' or 'Podcast Episode'
    release_year      INT         NOT NULL,
    duration_sec      INT         NOT NULL,
    ms_played         INT         NOT NULL,
    completion_rate   NUMERIC(5,3) NOT NULL,  -- 0.000 to 1.000
    skipped           VARCHAR(5)  NOT NULL,   -- 'Yes' or 'No'
    discovery_source  VARCHAR(40) NOT NULL,   -- 'Discover Weekly', 'Search', 'Home Feed', etc.
    device_type       VARCHAR(30) NOT NULL,
    explicit_flag     VARCHAR(5)  NOT NULL
);

CREATE INDEX idx_spotify_event_date ON spotify_events(event_date);
CREATE INDEX idx_spotify_country_tier ON spotify_events(country, subscription_tier);
CREATE INDEX idx_spotify_discovery ON spotify_events(discovery_source);

-- Load data in psql:
-- \copy spotify_events FROM 'data/spotify_listening_events.csv' WITH (FORMAT csv, HEADER true);
