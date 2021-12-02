SET SEARCH_PATH TO EducationStatus;

DROP TABLE IF EXISTS EnrollRateInst CASCADE;
CREATE TABLE EnrollRateInst (
    country TEXT NOT NULL,
    eduLevel TEXT NOT NULL,
    enrollRate FLOAT NOT NULL
);

DROP TABLE IF EXISTS EmploymentRate CASCADE;
CREATE TABLE EmploymentRates (
    country TEXT NOT NULL,
    eduLevel TEXT NOT NULL,
    employmentRate FLOAT NOT NULL
);   

CREATE VIEW NumEnroll AS
SELECT countryCode, eduLevel, sum(studentRate) as numEnroll
FROM Institution JOIN EducationLevel ON Institution.uID = EducationLevel.uID
WHERE Institution.year = 2019
GROUP BY uID;

CREATE VIEW totalNumEnroll AS 
SELECT sum(numEnroll) as totalEnrollPop
FROM NumEnroll;

INSERT INTO EnrollRateInst 
SELECT countryCode, eduLevel, (numEnroll * 100)/ (SELECT totalEnrollPop 
                                                    FROM totalNumEnroll) as enrollRate
FROM NumEnroll;

INSERT INTO EmploymentRate 
SELECT countryCode, eduLevel, sum(rate)
FROM EarnType JOIN EducationLevel ON EarnType.uID = EducationLevel.uID
WHERE EarnType.year = 2019
GROUP BY uID;
