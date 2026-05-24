USE opec_macro_db;

DROP VIEW IF EXISTS v_opec_analysis_ready;

CREATE VIEW v_opec_analysis_ready AS
SELECT
    gdp.country_code,
    gdp.year_id,
    (gdp.indicator_value / NULLIF(money.indicator_value, 0)) AS economic_velocity,
    growth.indicator_value AS gdp_growth_pct,
    trade.indicator_value AS trade_openness_pct,
    oil.indicator_value AS oil_rents_pct
FROM staging_world_bank_data gdp
LEFT JOIN staging_world_bank_data money
    ON gdp.country_code = money.country_code
    AND gdp.year_id = money.year_id
    AND money.indicator_code = 'FM.LBL.BMNY.CN'
LEFT JOIN staging_world_bank_data growth
    ON gdp.country_code = growth.country_code
    AND gdp.year_id = growth.year_id
    AND growth.indicator_code = 'NY.GDP.MKTP.KD.ZG'
LEFT JOIN staging_world_bank_data trade
    ON gdp.country_code = trade.country_code
    AND gdp.year_id = trade.year_id
    AND trade.indicator_code = 'NE.TRD.GNFS.ZS'
LEFT JOIN staging_world_bank_data oil
    ON gdp.country_code = oil.country_code
    AND gdp.year_id = oil.year_id
    AND oil.indicator_code = 'NY.GDP.PETR.RT.ZS'
WHERE gdp.indicator_code = 'NY.GDP.MKTP.CN';