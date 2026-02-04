# %%
import pandas as pd
import sqlalchemy

# %%

def import_query(path):
    with open(path) as open_file:
        query = open_file.read()
    return query

query = import_query("src/analytics/life_cycle.sql")
print(query)
# %%
engine_app = sqlalchemy.create_engine("sqlite:///data/loyalty-system/database.db")
engine_analytical = sqlalchemy.create_engine("sqlite:///data/analytics/database.db")
# %%
dates = [
    '2025-10-01',
    '2025-11-01',
    '2025-12-01',
    '2026-01-01',
]
# %%
for i in dates:
    with engine_analytical.connect() as conn:
        try:
            conn.execute(sqlalchemy.text(f"DELETE FROM life_cycle WHERE dtRef = date('{i}', '-1 day') OR dtRef IS null"))
            conn.commit()
        except Exception as err:
            print(err)

    print(i)
    query_format = query.format(date=i)
    df = pd.read_sql(query_format, engine_app)
    df.to_sql("life_cycle", engine_analytical, index=False, if_exists='append')
# %%
