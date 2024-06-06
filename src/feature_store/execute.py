from typing import List
import sqlalchemy
import pandas as pd
import datetime
import argparse
from tqdm import tqdm

def import_query(path: str) -> str:
    with open(path, 'r') as open_file:
        return open_file.read()
    
def date_range(start: str, stop: str) -> List:
    dt_start = datetime.datetime.strptime(start,"%Y-%m-%d")
    dt_stop = datetime.datetime.strptime(stop,"%Y-%m-%d")
    
    dates = []
    while dt_start <= dt_stop:
        dates.append(dt_start.strftime("%Y-%m-%d"))
        dt_start += datetime.timedelta(days=1)
    return dates

def ingest_date(query: str, table, dt) -> None:

    # Substituição de date por uma data
    query_fmt = query.format(date=dt)
    # Executa e trás o resultado para python
    df = pd.read_sql(query_fmt, origin_engine)
    df.head()

    # deleta a data de referência para garantir a integridade
    with target_engine.connect() as conn:
        try:
            state = f"DELETE FROM {table} WHERE dtRef = '{dt}';"
            conn.execute(sqlalchemy.text(state))
            conn.commit()
        except sqlalchemy.exc.OperationalError as err:
            print("tabela ainda não existe, criando ela ...")

    # Enviando o dado para o novo db
    df.to_sql(table, target_engine, index=False, if_exists='append')


now = datetime.datetime.now().strftime('%Y-%m-%d')

parser = argparse.ArgumentParser()
parser.add_argument("--feature_store", "-f", help="nome da feature store", type=str)
parser.add_argument("--start", "-s", help="data de inicio", default=now)
parser.add_argument("--stop", "-p", help="data de fim", default=now)
args = parser.parse_args()


origin_engine = sqlalchemy.create_engine("sqlite:///../../data/database.db")

target_engine = sqlalchemy.create_engine("sqlite:///../../data/feature_store.db")

# Import query
query = import_query(f'{args.feature_store}.sql')
dates = date_range(args.start, args.stop)

for i in tqdm(dates):
    ingest_date(query, args.feature_store, i)



