CREATE TABLE manual.hydration_events (
    id              SERIAL PRIMARY KEY,
    consumed_at     TIMESTAMPTZ NOT NULL,
    beverage_type   VARCHAR(20) NOT NULL CHECK (beverage_type IN ('water', 'sports_drink', 'coffee', 'milk', 'soda', 'alcohol', 'protein_shake', 'tea')),
    volume_oz       NUMERIC(5,1) NOT NULL CHECK (volume_oz > 0),
    notes           TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


CREATE VIEW manual.hydration_daily AS 
SELECT 
    date_trunc('day', consumed_at) AS day,
    SUM(volume_oz) AS total_oz,
    COUNT(*) AS entries
FROM manual.hydration_events
GROUP BY 1
ORDER BY 1 DESC;