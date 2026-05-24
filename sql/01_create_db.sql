CREATE DATABASE IF NOT EXISTS opec_macro_db;
USE opec_macro_db;

CREATE TABLE staging_world_bank_data (
    country_code    VARCHAR(3)      NOT NULL,
    year_id         INT             NOT NULL CHECK (year_id BETWEEN 1960 AND 2026),
    indicator_code  VARCHAR(50)     NOT NULL,
    indicator_value DOUBLE,
    inserted_at     TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (country_code, year_id, indicator_code)
);

DESCRIBE staging_world_bank_data;