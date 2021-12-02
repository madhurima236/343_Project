SET SEARCH_PATH TO EducationStatus;

DROP TABLE IF EXISTS EmploymentType CASCADE;
CREATE TABLE EnrollRateInst (
    country TEXT NOT NULL,
    eduLevel TEXT NOT NULL,
    employmentType TEXT NOT NULL,
    enrollRate FLOAT NOT NULL
);

CREATE VIEW finalCountries AS
SELECT countryCode
FROM EarnType JOIN EducationLevel ON EducationLevel.uID = EarnType.uID
WHERE EarnType.year = 2019
GROUP BY countryCode
HAVING count(distinct type) == 3 and count(distinct eduLevel) == 3;


INSERT INTO EmploymentType
SELECT finalCountries.countryCode, eduLevel, EarnType.type as employmentType, rate
FROM EarnType JOIN EducationLevel ON EducationLevel.uID = EarnType.uID
                JOIN finalCountries ON finalCountries.countryCode = EducationLevel.countryCode
WHERE EarnType.year = 2019;