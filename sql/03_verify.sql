USE opec_macro_db;

-- Preview raw data to confirm structure looks correct
SELECT * FROM staging_world_bank_data LIMIT 10;

-- Total number of records loaded from the API
SELECT COUNT(*) AS total_records FROM staging_world_bank_data;

-- Confirm all 12 OPEC countries are present
SELECT DISTINCT country_code FROM staging_world_bank_data;

-- Confirm all 6 indicators are present
SELECT DISTINCT indicator_code FROM staging_world_bank_data;

-- Row count per country per indicator (spot missing data)
SELECT country_code, indicator_code, COUNT(*) AS row_count
FROM staging_world_bank_data
GROUP BY country_code, indicator_code
ORDER BY country_code, indicator_code;

-- Year coverage per country per indicator (spot gaps in time range)
SELECT country_code, indicator_code, MIN(year_id) AS earliest_year, MAX(year_id) AS latest_year
FROM staging_world_bank_data
GROUP BY country_code, indicator_code
ORDER BY country_code, indicator_code;

-- Confirm the view was created successfully
SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- Preview the view output
SELECT * FROM v_opec_analysis_ready LIMIT 20;

-- Total rows in the view
SELECT COUNT(*) AS total_view_records FROM v_opec_analysis_ready;

-- Confirm all 12 countries came through the JOINs
SELECT DISTINCT country_code FROM v_opec_analysis_ready;

-- How many years of data each country has in the view
SELECT country_code, COUNT(*) AS year_count
FROM v_opec_analysis_ready
GROUP BY country_code
ORDER BY country_code;

-- Check for any rows where economic velocity couldn't be calculated
SELECT * FROM v_opec_analysis_ready
WHERE economic_velocity IS NULL;