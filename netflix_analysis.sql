CREATE TABLE shows (
    show_id TEXT PRIMARY KEY,
    type TEXT,
    title TEXT,
    director TEXT,
    country TEXT,
    date_added TEXT,  -- Will convert later to DATE format
    release_year INT,
    rating TEXT,
    duration TEXT,  -- Will clean later
    listed_in TEXT
);

Select * From shows
limit 10


-- Part 1: Data cleaning
-- Step 1: Check for Missing Values
SELECT 
    COUNT(*) AS total_rows,
    COUNT(show_id) AS show_id_count,
    COUNT(type) AS type_count,
    COUNT(title) AS title_count,
    COUNT(director) AS director_count,
    COUNT(country) AS country_count,
    COUNT(date_added) AS date_added_count,
    COUNT(release_year) AS release_year_count,
    COUNT(rating) AS rating_count,
    COUNT(duration) AS duration_count,
    COUNT(listed_in) AS listed_in_count
FROM shows;

-- Result: No values missing

-- Step 2: Check Data Types
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'shows';

--  Step 3: Fix Incorrect Data Types
-- date_added is stored as TEXT, but we need it as a DATE
ALTER TABLE shows 
ALTER COLUMN date_added TYPE DATE 
USING TO_DATE(date_added, 'MM/DD/YYYY');

-- Part 2: Content Strategy Analysis (What Type of Content is Popular?)
-- Question 1: What is the Ratio of Movies vs. TV Shows on Netflix?
SELECT type, COUNT(*) AS count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM shows), 2) AS percentage,
    CONCAT(ROUND(COUNT(*)::NUMERIC / (SELECT COUNT(*) FROM shows WHERE type = 'TV Show'), 2),
        ':1') AS movie_tv_ratio
FROM shows
GROUP BY type;

-- Question 2: What Are the Most Common Genres on Netflix?
SELECT 
    unnest(string_to_array(listed_in, ', ')) AS genre, 
    COUNT(*) AS count, 
	Round(100 * Count(*)/(Select Count(*)From shows),1) AS Percentage
FROM shows
GROUP BY genre
ORDER BY count DESC
Limit 10;

-- Question 3: Which Countries Produce the Most Netflix Content?
SELECT 
    country, 
    COUNT(*) AS count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM shows WHERE country IS NOT NULL), 2) AS percentage
FROM shows
WHERE country IS NOT NULL
GROUP BY country
ORDER BY count DESC
LIMIT 10;

-- Question 4: How has Netflix’s content library changed over time?
WITH yearly_counts AS (
    SELECT 
        EXTRACT(YEAR FROM date_added) AS year_added, 
        COUNT(*) AS count
    FROM shows
    WHERE date_added IS NOT NULL
    GROUP BY year_added
)
SELECT 
    year_added, 
    count, 
    LAG(count) OVER (ORDER BY year_added) AS previous_year_count,
    ROUND(
        100.0 * (count - LAG(count) OVER (ORDER BY year_added)) / NULLIF(LAG(count) OVER (ORDER BY year_added), 0), 
        2
    ) AS growth_percentage
FROM yearly_counts
ORDER BY year_added;

-- Part 2: User Engagement Analysis (What Attracts Viewers?)
-- Question 1: What Are the Most Popular Content Ratings on Netflix?
SELECT 
    rating, 
    COUNT(*) AS count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM shows WHERE rating IS NOT NULL), 2) AS percentage
FROM shows
WHERE rating IS NOT NULL
GROUP BY rating
ORDER BY count DESC;

-- Is Netflix focusing more on recent releases or older content?
SELECT 
    CASE 
        WHEN release_year >= 2015 THEN 'Recent (2015-Present)'
        WHEN release_year BETWEEN 2000 AND 2014 THEN 'Moderately Old (2000-2014)'
        ELSE 'Older Content (Before 2000)'
    END AS content_category,
    COUNT(*) AS count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM shows WHERE release_year IS NOT NULL), 2) AS percentage
FROM shows
WHERE release_year IS NOT NULL
GROUP BY content_category
ORDER BY percentage DESC;






