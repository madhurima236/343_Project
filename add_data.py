import psycopg2 as pg
import pandas as pd


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


def add_data(db_conn, query, parameters):
    cursor = db_conn.cursor()
    try:
        cursor.execute(query, parameters)
        db_conn.commit()
    except (Exception, pg.DatabaseError) as error:
        print("Error: %s" % error)
        return 1
    return 0


if __name__ == "__main__":
    db_conn = connect_db("csc343h-duttama1", "duttama1", "")

    df1 = pd.read_csv("cleaned databases/edu_earnings.csv")

    # create the country db
    country_db = df1[["Country code", "Country"]]
    country_db = country_db.drop_duplicates()
    query = "Insert into Country values (%s, %s)"

    for index, tuple in country_db.iterrows():
        param = [tuple["Country code"], tuple["Country"]]
        add_data(db_conn, query, param)

    # create the EducationLevel db
    eduLevel_db = df1[["COUNTRY", "ISC11A.1"]]
    query = "Insert into EducationLevel values (%s, %s, %s)"

    for index, tuple in eduLevel_db.iterrows():
        param = [index, tuple["COUNTRY"], tuple["ISC11A.1"]]
        add_data(db_conn, query, param)

    # create earnType db
    earnType_db = df1[
        ["Country code", "Education Level", "Earn category", "Year", "Value"]
    ]
    query = "Insert into earnType values ((SELECT uID \
                                                FROM EducationLevel \
                                                WHERE countryCode=(%s) and eduLevel=(%s)), %s, %s)"

    for index, tuple in earnType_db.iterrows():
        param = [
            tuple["Country code"],
            tuple["Education level"],
            tuple["Earn category"],
            tuple["Value"],
            tuple["Year"],
        ]
        add_data(db_conn, query, param)

    df2 = pd.read_csv("cleaned databases/enroll_field.csv")

    # create the FieldStudy db
    fieldStudy_db = (
        df2.groupby(
            ["Country code", "Field", "International mobility", "Education level"]
        )["Value"]
        .sum()
        .reset_index(name="Value")
    )
    query = "Insert into EducationLevel values ((SELECT uID \
                                                FROM EducationLevel \
                                                WHERE countryCode=(%s) and eduLevel=(%s)), %s, %s)"

    for index, tuple in fieldStudy_db.iterrows():
        param = [
            tuple["Country code"],
            tuple["Education level"],
            tuple["Field"],
            tuple["Value"],
            tuple["International mobility"],
        ]
        add_data(db_conn, query, param)

    df3 = pd.read_csv("cleaned databases/enroll_institution_type.csv")

    # create the institution db
    institution_db = df3[
        [
            "Country code",
            "Education level",
            "Reference sector",
            "Employment type",
            "Year",
            "Value",
        ]
    ]
    query = "Insert into EducationLevel values ((SELECT uID \
                                                FROM EducationLevel \
                                                WHERE countryCode=(%s) and eduLevel=(%s)), %s, %s)"

    for index, tuple in fieldStudy_db.iterrows():
        param = [
            tuple["Country code"],
            tuple["Education level"],
            tuple["Reference sector"],
            tuple["Value"],
            tuple["Employment type"],
            tuple["Year"],
        ]
        add_data(db_conn, query, param)
