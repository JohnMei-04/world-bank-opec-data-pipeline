# World Bank API Data Pipeline(OPEC Economic Indicators)

## Overview
This project creates an end to end data pipeline that collects macroeconomic 
indicators for 12 OPEC member nations using the World Bank Open Data API. 
Raw data is collected using Python, processed using pandas, stored in a MySQL 
staging table, transformed into an analysis ready format using SQL views, 
and visualized in an interactive Power BI dashboard.

The dashboard explores key economic themes across OPEC nations between 1960 
and 2024, covering GDP growth trends, oil rent dependency, trade openness, 
and broad money supply. A calculated metric called Economic Velocity is also 
included, measuring how efficiently each nation converts its money supply 
into economic output.

---
## Dashboard Preview
[View Live Dashboard](https://app.powerbi.com/groups/me/reports/23074062-94e4-4f0d-8c38-bb41921cc59c/70ce0e486677ecd021fc?experience=power-bi)

## Tech Stack
| Tool           | Purpose                                      |
|----------------|----------------------------------------------|
| Python         | Runs the data pipeline from start to finish  |
| pandas         | Cleans and organizes the data before loading |
| requests       | Makes the API calls to the World Bank        |
| SQLAlchemy     | Connects Python to the MySQL database        |
| pymysql        | Let's SQLAlchemy speak to MySQL specifically |
| python-dotenv  | Keeps database crfedentials out of the code  |
| MySQL          | Storage and transformation of raw data       |
| PowerBI        | Turns the data into an interactive dashboard |
| World Bank API | Source of economic data                      |
---

## Project Structure
```
PyCharmMiscProject/
│
├── .venv
├── .env
├── .gitignore
├── README.md
├── scraper.py
└── sql/
    ├── 01_create_db.sql
    ├── 02_create_view.sql
    └── 03_verify.sql
```
---

## Countries Covered
12 OPEC member nations:

| Code | Country |
|---|---|
| DZA | Algeria |
| COG | Republic of Congo |
| GNQ | Equatorial Guinea |
| GAB | Gabon |
| IRN | Iran |
| IRQ | Iraq |
| KWT | Kuwait |
| LBY | Libya |
| NGA | Nigeria |
| SAU | Saudi Arabia |
| ARE | United Arab Emirates |
| VEN | Venezuela |

---

## Indicators
| Name           | World Bank Code   | Description                                    |
|----------------|-------------------|------------------------------------------------|
| GDP Growth     | NY.GDP.MKTP.KD.ZG | Annual GDP growth rate as a percentage         |
| Nominal GDP    | NY.GDP.MKTP.CN    | Total GDP measured in local currency units     |
| Trade Openness | NE.TRD.GNFS.ZS    | Total trade as a percentage of GDP             |
| Oil Rents      | NY.GDP.PETR.RT.ZS | Oil rents as a percentage of GDP               |
| Broad Money    | FM.LBL.BMNY.CN    | Total money supply in local currency units     |
| Gross Capital  | NE.GDI.TOTL.ZS    | Gross capital formation as a percentage of GDP |

---

## Derived Metric
**Economic Velocity** = Nominal GDP / Broad Money Supply

Measures how efficiently a country converts its money supply into economic 
output. A higher value means more economic activity is being generated per 
unit of money in circulation. A lower value suggests the economy is not 
making full use of its available money supply.

This metric is calculated directly in the SQL view following the principle 
of separation of concerns. Python handles data collection, MySQL handles 
data transformation. This means any tool connecting to the database gets 
the metric automatically without needing to recalculate it.

---

## Data Pipeline
1. Python sends 72 API requests to the World Bank (12 countries × 6 indicators)
2. pandas organizes the responses into a structured dataframe
3. MySQL staging table is truncated to preserve the schema
4. Fresh data is appended to the staging table via SQLAlchemy
5. SQL view joins all 6 indicators and calculates Economic Velocity
6. Power BI connects directly to the view for visualization

---

## Known Data Limitations
The following data gaps exist in the World Bank database and are not errors 
in the pipeline. NULL values are retained intentionally to preserve data 
integrity rather than being silently dropped.

### Gaps Within the Recommended 2005-2013 Window
These directly impact analysis and should be considered when interpreting results:

| Country | Indicator      | Issue                                                              |
|---------|----------------|--------------------------------------------------------------------|
| NGA     | Trade Openness | Only 1 data point exists in the entire World Bank record (1960)    |
| NGA     | Gross Capital  | No data exists in the World Bank database for this indicator       |
| GNQ     | Trade Openness | Data only begins in 2005, the first year of the recommended window |
| GNQ     | Gross Capital  | Data only begins in 2005, the first year of the recommended window |

### Gaps Outside the Recommended 2005-2013 Window
These affect analysis of the full historical range only:

| Country | Indicator      | Issue                        |
|---------|----------------|------------------------------|
| DZA     | Oil Rents      | No data before 1970          |
| IRN     | Broad Money    | Data ends at 2016            |
| IRQ     | Broad Money    | No data before 2004          |
| SAU     | Broad Money    | Data ends at 2017            |
| SAU     | Oil Rents      | No data after 2021           |
| GAB     | Broad Money    | Data ends at 2019            |
| GAB     | Oil Rents      | No data after 2021           |
| VEN     | Broad Money    | Data ends at 2013            |
| VEN     | Oil Rents      | No data after 2014           |
| KWT     | Broad Money    | No data for 1990             |
| KWT     | Oil Rents      | Data ends at 2020            |
| LBY     | Oil Rents      | No data after 2021           |
| LBY     | Gross Capital  | Data only begins in 1990     |
| ARE     | Trade Openness | Data only begins in 2001     |
| ARE     | Gross Capital  | Data only begins in 2001     |
| ARE     | Oil Rents      | No data after 2021           |
| GNQ     | All indicators | Very sparse data before 1980 |

### Recommendation
For the most complete and comparable analysis across all 12 countries, 
filter the dashboard to **2005-2013** using the year slicer. The full 
historical range remains available for exploratory analysis but should 
be interpreted with the limitations above in mind.

### Impact on Derived Metric
Economic Velocity is calculated by dividing Nominal GDP by Broad Money Supply.
This means if Broad Money data is missing for a country in a given year, 
Economic Velocity cannot be calculated and will appear as NULL in the dashboard.

Within the recommended 2005-2013 window this mainly affects Nigeria, where 
Broad Money data exists but Trade Openness and Gross Capital are missing. 
Outside this window it also affects Iran, Saudi Arabia, Venezuela, and Gabon 
where Broad Money data ends before or after the full historical range.

These NULL values are kept in the dashboard intentionally to accurately 
reflect what the World Bank does and does not report, rather than hiding 
gaps in the data.

---

## How to Run

### Prerequisites
- Python 3.x
- MySQL Server
- MySQL Workbench
- Power BI Desktop
- MySQL Connector for Power BI

### Setup
1. Clone or download the repository
2. Install Python dependencies:
```
pip install pandas requests sqlalchemy pymysql python-dotenv cryptography
```
3. Create a `.env` file in the project root and add your MySQL password:
```
MYSQL_PASSWORD=yourpassword
```
4. Start your MySQL server
### Running the Pipeline
1. Run `sql/01_create_db.sql` in MySQL Workbench — only needed once
2. Run `scraper.py` in PyCharm or your terminal
3. Run `sql/02_create_view.sql` in MySQL Workbench
4. Run `sql/03_verify.sql` to confirm everything loaded correctly
5. Open Power BI, connect to `opec_macro_db`, and load `v_opec_analysis_ready`

### Refreshing Data
To pull the latest data from the World Bank API simply rerun `scraper.py`. 
The pipeline automatically truncates the staging table and reloads it with 
fresh data. The view and Power BI dashboard update instantly on refresh.

---

## Dependencies
pandas

requests

sqlalchemy

pymysql

python-dotenv

cryptography

---

## Author
Junxi (John) Mei

github: https://github.com/JohnMei-04

linkedin: www.linkedin.com/in/junxi-mei
