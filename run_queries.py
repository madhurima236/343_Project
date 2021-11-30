import psycopg2 as pg
import pandas as pd
import re
import psycopg2.extras 

def connect_db(dbname, user, pword):
    try:
        db_conn = pg.connect(dbname=dbname, user=user, password=pword)
    except pg.Error:
        return False

    return db_conn


def disconnect_db(db_conn):
    try:
        db_conn.close()
    except pg.Error:
        return False

    return True


def _create_df(cursor):
    pass
    data = []
    for record in cursor:
        data.append(record)

    df = pd.Dataframe(data)
    
    return df


def run_query_1(db_conn):
    pass
    cursor = db_conn.cursor(cursor_factory=pg.extras.DictCursor)
    cursor.execute("SET SEARCH_PATH TO EducationStatus;")

    # Query for q1

    return _create_df(cursor)

def run_query_2(db_conn):
    pass
    cursor = db_conn.cursor(cursor_factory=pg.extras.DictCursor)
    cursor.execute("SET SEARCH_PATH TO EducationStatus;")

    # Query for q2

    return _create_df(cursor)

def run_query_3(db_conn):
    pass
    cursor = db_conn.cursor(cursor_factory=pg.extras.DictCursor)
    cursor.execute("SET SEARCH_PATH TO EducationStatus;")

    # Query for q3

    return _create_df(cursor)
    

if __name__ == "__main__":
    db_conn = connect_db("csc343h-duttama1", "duttama1", "")

    q1_df = run_query_1(db_conn)
    q2_df = run_query_2(db_conn)
    q3_df = run_query_3(db_conn)
    
    disconnect_db(db_conn)
