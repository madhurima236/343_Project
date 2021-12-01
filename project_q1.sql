SET SEARCH_PATH TO EducationStatus;

DROP TABLE IF EXISTS FieldStudyRates CASCADE;
CREATE TABLE FieldStudyRates (
    country TEXT NOT NULL,
    eduLevel TEXT NOT NULL,
    field TEXT NOT NULL, 
    enrollPercent FLOAT NOT NULL
);

DROP TABLE IF EXISTS UnemploymentRates CASCADE;
CREATE TABLE UnemploymentRates (
    country TEXT NOT NULL,
    avgRate FLOAT NOT NULL
);   

-- Total enrolled in each field of study, grouped over mobility
DROP VIEW IF EXISTS total_field_enrolled CASCADE;

CREATE VIEW total_field_enrolled AS
SELECT uID, field, sum(enrollRate) AS numEnrolled
FROM FieldStudy
GROUP BY uID, field;

-- Total enrolled in each level of study (uID)
DROP VIEW IF EXISTS total_enrolled CASCADE;

CREATE VIEW total_enrolled AS
SELECT uID, sum(numEnrolled) AS totalEnrolled
FROM total_field_enrolled
GROUP BY uID;

-- Proportion enrolled in each field of study 
DROP VIEW IF EXISTS enrolled_prop CASCADE;

CREATE VIEW enrolled_prop AS
SELECT uID, field, numEnrolled/totalEnrolled * 100 AS enrollPercent
FROM total_field_enrolled JOIN total_enrolled USING (uID);

-- Proportion enrolled in each field of study by education level and country name 
insert into FieldStudyRates
SELECT name AS country, eduLevel, field, enrollPercent
FROM enrolled_prop JOIN 
(SELECT uID, name, eduLevel 
FROM EducationLevel JOIN Country ON EducationLevel.countryCode = Country.code) c
ON enrolled_prop.uID = c.uID
ORDER BY country, field, eduLevel;

-- select countryCode, eduLevel, field
-- from FieldStudy JOIN EducationLevel ON FieldStudy.uID = EducationLevel.uID
-- order by countryCode, eduLevel, field;

-- Total unemployment rate by country
DROP VIEW IF EXISTS total_unemployment CASCADE;

CREATE VIEW total_unemployment AS
SELECT name AS country, year, sum(unempRate) AS totalUnempRate
FROM GenderUnemployment JOIN Country ON GenderUnemployment.countryCode = Country.code
GROUP BY country, year
ORDER BY country, year;

-- Average overall unemployment rate by country 
insert into UnemploymentRates
SELECT country, avg(totalUnempRate) AS avgUnempOverYears
FROM total_unemployment
GROUP BY country;
