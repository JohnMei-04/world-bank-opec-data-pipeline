import itertools
import time

import pandas as pd
import requests as rq

from sqlalchemy import create_engine, text
from dotenv import load_dotenv
import os

load_dotenv()

countries = ['DZA', 'COG', 'GNQ', 'GAB', 'IRN', 'IRQ', 'KWT', 'LBY', 'NGA', 'SAU', 'ARE', 'VEN']

indicators = {
    "GDP_Growth": "NY.GDP.MKTP.KD.ZG",
    "Nominal_GDP_LCU": "NY.GDP.MKTP.CN",
    "Trade_Openness": "NE.TRD.GNFS.ZS",
    "Oil_Rents": "NY.GDP.PETR.RT.ZS",
    "Broad_Money_LCU": "FM.LBL.BMNY.CN",
    "Gross_Capital": "NE.GDI.TOTL.ZS",
}
all_records = []
request_matrix = list(itertools.product(countries, indicators.items()))
print(f"Total API requests to execute: {len(request_matrix)}")

for country, (indicator_name, indicator_code) in request_matrix:
    url = f"https://api.worldbank.org/v2/country/{country}/indicator/{indicator_code}?format=json&per_page=1000"

    try:
        response = rq.get(url, timeout=10)
        if response.status_code == 200:
            data = response.json()

            if len(data) > 1 and data[1] is not None:
                for datapoint in data[1]:
                    year = datapoint.get('date')
                    value = datapoint.get('value')

                    if value is not None:
                        all_records.append(
                            {
                                'country_code': country,
                                'year_id': int(year),
                                'indicator_code': indicator_code,
                                'indicator_value': float(value),
                            }
                        )
                print(f"✅ {country} | {indicator_name} | records so far: {len(all_records)}")
            else:
                print(f"⚠️ No data returned for {country} | {indicator_name}")
        else:
            print(f"⚠️ {response.status_code} for {country} | {indicator_name}")

        time.sleep(0.1)

    except rq.exceptions.RequestException as e:
        print(f"❌ Request failed for {indicator_name} | {country}: {e}")
    except Exception as e:
        print(f"❌ Unexpected error for {indicator_name} | {country}: {e}")

print(f"Total records collected: {len(all_records)}")

df = pd.DataFrame(all_records)
print(df['country_code'].unique())
print(df['indicator_code'].unique())
print(df.head(20))
print(df.tail(20))
print(df.shape)

engine = create_engine(
    f"mysql+pymysql://root:{os.environ.get('MYSQL_PASSWORD')}@localhost:3306/opec_macro_db"
)

with engine.connect() as conn:
    conn.execute(text("TRUNCATE TABLE staging_world_bank_data"))
    conn.commit()

df.to_sql(
    name='staging_world_bank_data',
    con=engine,
    if_exists='append',
    index=False
)

print(f"✅ {len(df)} records pushed to MySQL")
