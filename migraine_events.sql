CREATE TABLE manual.migraine_events (
    id          SERIAL PRIMARY KEY,
    onset       TIMESTAMPTZ,
    ended       TIMESTAMPTZ,
    severity    SMALLINT CHECK (severity BETWEEN 1 AND 5),
    excedrin_pills SMALLINT CHECK (excedrin_pills BETWEEN 1 AND 3),
    hydration_yesterday VARCHAR(10) CHECK (hydration_yesterday IN ('poor', 'normal', 'good')),
    notes       TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT at_least_one_time CHECK (onset IS NOT NULL OR ended IS NOT NULL)
);
