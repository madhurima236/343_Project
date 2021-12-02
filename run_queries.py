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


def _create_df(cursor, column_names):
    data = []
    for record in cursor:
        data.append(record)

    df = pd.DataFrame(data, columns=column_names)
    
    return df


def run_query_1(db_conn):
    cursor = db_conn.cursor(cursor_factory=pg.extras.DictCursor)
    cursor.execute("SET SEARCH_PATH TO EducationStatus;")

    # Query for q1
    cursor.execute("SELECT * FROM fieldstudyrates;")
    fieldstudyrates_df = _create_df(cursor, ["country", "eduLevel", "field", "enrollPercent" ])
    fieldstudyrates_df.to_csv("db after queries/fieldStudyRates")
    
    cursor.execute("SELECT * FROM unemploymentrates;")
    unemploymentrates_df = _create_df(cursor, ["country","avgRate"])
    unemploymentrates_df.to_csv("db after queries/unemploymentRates")

def run_query_2(db_conn):
    cursor = db_conn.cursor(cursor_factory=pg.extras.DictCursor)
    cursor.execute("SET SEARCH_PATH TO EducationStatus;")

    # Query for q2
    cursor.execute("SELECT * FROM EnrollRateInst;")
    EnrollRateInst_df = _create_df(cursor, ["country","eduLevel" ,"enrollRate"])
    EnrollRateInst_df.to_csv("db after queries/EnrollRateInst")
    
    cursor.execute("SELECT * FROM CountryEmploymentRates;")
    EmploymentRates_df = _create_df(cursor, ["country","eduLevel" ,"employmentRate"])
    EmploymentRates_df.to_csv("db after queries/EmploymentRates")
    

def run_query_3(db_conn):
    cursor = db_conn.cursor(cursor_factory=pg.extras.DictCursor)
    cursor.execute("SET SEARCH_PATH TO EducationStatus;")

    # Query for q3

    cursor.execute("SELECT * FROM EmploymentType;")
    EmploymentType_df = _create_df(cursor, ["country", "eduLevel", "employmentType", "enrollRate"])
    EmploymentType_df.to_csv("db after queries/EmploymentType")
    

if __name__ == "__main__":
    db_conn = connect_db("csc343h-duttama1", "duttama1", "")

    run_query_1(db_conn)
    run_query_2(db_conn)
    run_query_3(db_conn)
    
    disconnect_db(db_conn)
