SET SEARCH_PATH TO EducationStatus;

DROP TABLE IF EXISTS EnrollRateInst CASCADE;
CREATE TABLE EnrollRateInst (
    country TEXT NOT NULL,
    eduLevel TEXT NOT NULL,
    enrollRate FLOAT NOT NULL
);

DROP TABLE IF EXISTS CountryEmploymentRates CASCADE;
CREATE TABLE CountryEmploymentRates (
    country TEXT NOT NULL,
    eduLevel TEXT NOT NULL,
    employmentRate FLOAT NOT NULL
);   

DROP VIEW IF EXISTS finalCountries CASCADE;

CREATE VIEW finalCountries AS
SELECT countryCode
FROM EducationLevel 
GROUP BY countryCode
HAVING count(distinct eduLevel) = 3;

DROP VIEW IF EXISTS NumEnroll CASCADE;

CREATE VIEW NumEnroll AS
SELECT EducationLevel.countryCode, eduLevel, sum(studentRate) as numEnroll
FROM Institution JOIN EducationLevel ON Institution.uID = EducationLevel.uID
        -- JOIN finalCountries ON EducationLevel.countryCode = finalCountries.countryCode
WHERE Institution.year = 2018
GROUP BY EducationLevel.uID;

DROP VIEW IF EXISTS totalNumEnroll CASCADE;

CREATE VIEW totalNumEnroll AS 
SELECT sum(numEnroll) as totalEnrollPop
FROM NumEnroll;

INSERT INTO EnrollRateInst 
SELECT countryCode, eduLevel, (numEnroll * 100)/ (SELECT totalEnrollPop 
                                                    FROM totalNumEnroll) as enrollRate
FROM NumEnroll;

INSERT INTO CountryEmploymentRates
SELECT EducationLevel.countryCode, eduLevel, sum(rate)
FROM EarnType JOIN EducationLevel ON EarnType.uID = EducationLevel.uID
    -- JOIN finalCountries ON EducationLevel.countryCode = finalCountries.countryCode
WHERE EarnType.year = 2018
GROUP BY EducationLevel.uID;
