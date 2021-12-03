SET SEARCH_PATH TO EducationStatus;

-- Table consisting of enrollment rate in each country 
-- for each level of tertiary education
DROP TABLE IF EXISTS EnrollRateInst CASCADE;
CREATE TABLE EnrollRateInst (
    country TEXT NOT NULL,
    eduLevel TEXT NOT NULL,
    enrollRate FLOAT NOT NULL
);

-- Table consisting of employment rate in each country 
-- for each level of tertiary education
DROP TABLE IF EXISTS CountryEmploymentRates CASCADE;
CREATE TABLE CountryEmploymentRates (
    country TEXT NOT NULL,
    eduLevel TEXT NOT NULL,
    employmentRate FLOAT NOT NULL
);   

-- View consisting of total population enrolled in each level of tertiary
-- education in a country for the year 2019
DROP VIEW IF EXISTS NumEnroll CASCADE;
CREATE VIEW NumEnroll AS
SELECT EducationLevel.countryCode, eduLevel, sum(studentRate) as numEnroll
FROM Institution JOIN EducationLevel ON Institution.uID = EducationLevel.uID
WHERE Institution.year = 2019
GROUP BY EducationLevel.uID;

-- View consistiong of total population in each country
DROP VIEW IF EXISTS totalNumEnroll CASCADE;
CREATE VIEW totalNumEnroll AS 
SELECT countryCode, sum(numEnroll) as totalEnrollPop
FROM NumEnroll
GROUP BY countryCode;

-- Calculate the enrollment rate and insert the data respectively
INSERT INTO EnrollRateInst 
SELECT Country.name, eduLevel, (numEnroll * 100)/ totalEnrollPop as enrollRate
FROM NumEnroll JOIN Country ON NumEnroll.countryCode = Country.code
            JOIN totalNumEnroll ON totalNumEnroll.countryCode = Country.code;


-- Insert the data respectively for the year 2019
INSERT INTO CountryEmploymentRates
SELECT Country.name, eduLevel, sum(rate)
FROM EarnType JOIN EducationLevel ON EarnType.uID = EducationLevel.uID 
            JOIN Country ON EducationLevel.countryCode = Country.code
WHERE EarnType.year = 2019
GROUP BY Country.name, EducationLevel.eduLevel;
