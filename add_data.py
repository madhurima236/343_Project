import psycopg2 as pg
import pandas as pd
import re
import psycopg2.extras 

get_uID_query = "(SELECT uID \
                    FROM EducationLevel \
                    WHERE countryCode=(%s) and eduLevel=(%s));"

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
    cursor.execute("SET SEARCH_PATH TO EducationStatus;")
    try:
        cursor.execute(query, parameters)
        db_conn.commit()
        cursor.close()
    except (Exception, pg.DatabaseError) as error:
        print("Error: %s" % error)
        return 1
    return 0

def get_uID(db_conn, query, param):
    cursor = db_conn.cursor(cursor_factory=pg.extras.DictCursor)
    cursor.execute("SET SEARCH_PATH TO EducationStatus;")
    try:
        cursor.execute(query, param)
        for record in cursor:
            return record[0]

    except (Exception, pg.DatabaseError) as error:
        print("Error: %s" % error)
        return 1

def get_country_code(db_conn, query, param):
    cursor = db_conn.cursor(cursor_factory=pg.extras.DictCursor)
    cursor.execute("SET SEARCH_PATH TO EducationStatus;")
    try:
        cursor.execute(query, param)
        for record in cursor:
            return record[0]

    except (Exception, pg.DatabaseError) as error:
        print("Error: %s" % error)
        return 1


if __name__ == "__main__":
    db_conn = connect_db("csc343h-duttama1", "duttama1", "")

    df1 = pd.read_csv("cleaned databases/edu_earnings.csv")
    df2 = pd.read_csv("cleaned databases/enroll_field.csv")
    df3 = pd.read_csv("cleaned databases/enroll_institution_type.csv")

    # create the country db
    country_db = pd.concat([df1[["Country code", "Country"]], df2[["Country code", "Country"]], df3[["Country code", "Country"]]])
    country_db = country_db.drop_duplicates()
    query = "Insert into Country values (%s, %s);"

    for index, tuple in country_db.iterrows():
        param = [tuple["Country code"], tuple["Country"]]
        add_data(db_conn, query, param)

    print("created country db")

    # create the EducationLevel db
    eduLevel_db = pd.concat([df1[["Country code", "Education Level"]], df2[["Country code", "Education Level"]], df3[["Country code", "Education Level"]]])
    eduLevel_db = eduLevel_db.drop_duplicates()
    query = "Insert into EducationLevel values (%s, %s, %s);"
    i = 0

    for index, tuple in eduLevel_db.iterrows():
        edu_level = re.sub("’", "", tuple["Education Level"])
        param = [i, tuple["Country code"], edu_level]
        add_data(db_conn, query, param)
        i += 1
    print("created education level db")

    # create earnType db
    earnType_db = df1[
        ["Country code", "Education Level", "Earn category", "Year", "Value"]
    ]
    earnType_db = earnType_db.drop_duplicates(subset=["Country code", "Education Level", "Earn category", "Year"])
    insert_query = "Insert into earnType values (%s, %s, %s, %s)"

    for index, tuple in earnType_db.iterrows():
        edu_level = re.sub("’", "", tuple["Education Level"])
        year = str(tuple["Year"]).replace(".0","")
        uID = get_uID(db_conn, get_uID_query, [tuple["Country code"], edu_level] )
        if uID is not None:
            param = [
                str(uID),
                tuple["Earn category"],
                tuple["Value"],
                year,
            ]
            add_data(db_conn, insert_query, param)
    
    print("created earnType db")

    # create the FieldStudy db
    fieldStudy_db = (
        df2.groupby(
            ["Country code", "Field", "Education Level", "International mobility"]
        )["Value"]
        .sum()
        .reset_index(name="Value")
    )
    fieldStudy_db = fieldStudy_db.drop_duplicates(subset=['Country code', 'Field', 'Education Level', "International mobility" ])

    insert_query = "INSERT INTO FieldStudy VALUES (%s, %s, %s, %s);"

    for index, tuple in fieldStudy_db.iterrows():
        edu_level = re.sub("’", "", tuple["Education Level"])
        uID = get_uID(db_conn, get_uID_query, [tuple["Country code"], edu_level] )
        if uID is not None:
            param = [
                str(uID),
                tuple["Field"],
                tuple["Value"],
                tuple["International mobility"]
            ]
            add_data(db_conn, insert_query, param)

    print("created Field db")

    # create the institution db
    institution_db = df3[
        [
            "Country code",
            "Education Level",
            'Reference sector',
            "Employment type",
            "Year",
            "Value",
        ]
    ]

    insert_query = "Insert into Institution values ((%s), (%s), (%s), (%s), (%s))"

    for index, tuple in institution_db.iterrows():
        edu_level = re.sub("’", "", tuple["Education Level"])
        uID = get_uID(db_conn, get_uID_query, [tuple["Country code"], edu_level] )
        if uID is not None:
            param = [
                str(uID),
                tuple['Reference sector'],
                tuple["Value"],
                tuple["Employment type"],
                tuple["Year"],
            ]
            add_data(db_conn, insert_query, param)

    print("created institution db")

    # create GenderUnemployment db
    df4 = pd.read_csv("cleaned databases/gender_unemployment.csv")
    gender_db = df4[
        [
            "Country",
            "Sex",
            "Time", "Value",
        ]
    ]
    gender_db = gender_db.drop_duplicates(subset=['Country', 'Sex', 'Time'])
    country_query = "SELECT code FROM Country WHERE country.name = %s;"
    query = "Insert into GenderUnemployment values (%s, %s, %s, %s);"

    for index, tuple in gender_db.iterrows():
        countryCode = get_country_code(db_conn, country_query, [tuple["Country"]] )
        if countryCode is not None:
            param = [
                countryCode,
                tuple["Sex"],
                tuple["Value"],
                tuple["Time"],
            ]
            add_data(db_conn, query, param)
    
    print("created Gender db")
   
    disconnect_db(db_conn)
