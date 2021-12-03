SET SEARCH_PATH TO EducationStatus;

-- Table consisiting of employment rate for each country 
-- based on teriary education level and type of employment
DROP TABLE IF EXISTS EmploymentType CASCADE;
CREATE TABLE EmploymentType (
    country TEXT NOT NULL,
    eduLevel TEXT NOT NULL,
    employmentType TEXT NOT NULL,
    employmentRate FLOAT NOT NULL
);


-- List of countries whose data for employment rate exists for all three categories 
-- of education level and type of employment
DROP VIEW IF EXISTS finalCountries CASCADE;
CREATE VIEW finalCountries AS
SELECT countryCode
FROM EarnType JOIN EducationLevel ON EducationLevel.uID = EarnType.uID
WHERE EarnType.year = 2019
GROUP BY countryCode
HAVING count(distinct type) = 3 and count(distinct eduLevel) = 3;


-- Insert respective data from the year 2019
INSERT INTO EmploymentType
SELECT Country.name, eduLevel, EarnType.type as employmentType, rate
FROM EarnType JOIN EducationLevel ON EducationLevel.uID = EarnType.uID
                JOIN finalCountries ON finalCountries.countryCode = EducationLevel.countryCode
                JOIN Country ON EducationLevel.countryCode = Country.code
WHERE EarnType.year = 2019;