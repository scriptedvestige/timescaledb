-- Table creation and schema
CREATE TABLE obs_gap_log (
	id SERIAL PRIMARY KEY,
	 detected_at TIMESTAMPTZ DEFAULT NOW(),
	 gap_start TIMESTAMPTZ,
	 gap_end TIMESTAMPTZ,
	 gap_duration INTERVAL
);


-- Gap detection statement
WITH gaps AS (
    SELECT
        time as gap_end,
        LAG(time) OVER (ORDER BY time) as gap_start,
        time - LAG(time) OVER (ORDER BY time) as gap_duration
    FROM ws_observations
)
SELECT gap_start, gap_end, gap_duration
FROM gaps
WHERE gap_duration > INTERVAL '10 minutes'
ORDER BY gap_start;


-- Insert values into the table
INSERT INTO obs_gap_log (gap_start, gap_end, gap_duration)
WITH gaps AS (
    SELECT
        time as gap_end,
        LAG(time) OVER (ORDER BY time) as gap_start,
        time - LAG(time) OVER (ORDER BY time) as gap_duration
    FROM ws_observations
)
SELECT gap_start, gap_end, gap_duration
FROM gaps
WHERE gap_duration > INTERVAL '10 minutes'
ORDER BY gap_start;
