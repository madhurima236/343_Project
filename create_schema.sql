drop schema if exists EducationStatus cascade;

create schema EducationStatus;
set search_path to EducationStatus;

-- Country code for each country
CREATE TABLE Country (
    name TEXT NOT NULL,
    code TEXT NOT NULL,
    PRIMARY KEY (code)
);

-- Employment Rate by Gender in each country.
CREATE TABLE Gender (
	countryCode TEXT NOT NULL,
	gender TEXT NOT NULL,
	empRate FLOAT NOT NULL,
	PRIMARY KEY (countryCode)
    FOREIGN KEY (countryCode) REFERENCES Country(code)
);

-- Enrollment rate in different institution sectors.
CREATE TABLE Institution (
	uID INT NOT NULL,
	sector TEXT NOT NULL,
	studentRate FLOAT,
	PRIMARY KEY (uID, sector)
    FOREIGN KEY (uID) REFERENCES EducationLevel(uID)
);

-- Enrollment rate in different field of studies.
CREATE TABLE FieldStudy (
	uID INT NOT NULL,
	field TEXT NOT NULL,
	enrollRate FLOAT,
	PRIMARY KEY (uID, field)
    FOREIGN KEY (uID) REFERENCES EducationLevel(uID)
);

-- Enrollment rate in different institution sectors.
CREATE TABLE EarnType (
	uID INT NOT NULL,
	type TEXT NOT NULL,
	rate FLOAT,
	PRIMARY KEY (uID, type)
    FOREIGN KEY (uID) REFERENCES EducationLevel(uID)
);

-- Enrollment rate in different institution sectors.
CREATE TABLE EarnType (
	uID INT NOT NULL,
	countryCode TEXT NOT NULL,
	eduLevel TEXT NOT NULL,
	PRIMARY KEY (uID, countryCode)
);