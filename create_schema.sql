drop schema if exists EducationStatus cascade;

create schema EducationStatus;
set search_path to EducationStatus;

-- Country code for each country
CREATE TABLE Country (
    code TEXT NOT NULL,
    name TEXT NOT NULL,
    PRIMARY KEY (code)
);

-- Education level division for each country
CREATE TABLE EducationLevel (
	uID INT NOT NULL,
	countryCode TEXT NOT NULL,
	eduLevel TEXT NOT NULL,
	PRIMARY KEY (uID),
	FOREIGN KEY (countryCode) REFERENCES Country(code)
);

-- Unemployment Rate by Gender in each country.
CREATE TABLE GenderUnemployment (
	countryCode TEXT NOT NULL,
	gender TEXT NOT NULL,
	unempRate FLOAT NOT NULL,
    year INT,
	PRIMARY KEY (countryCode, gender, year),
	FOREIGN KEY (countryCode) REFERENCES Country(code)
);

-- Enrollment rate in different institution sectors.
CREATE TABLE Institution (
	uID INT NOT NULL,
	sector TEXT NOT NULL,
	studentRate FLOAT NOT NULL,
    employmentType TEXT, 
    year INT,
	PRIMARY KEY (uID, sector, employmentType, year),
    FOREIGN KEY (uID) REFERENCES EducationLevel(uID)
);

-- Enrollment rate in different field of studies.
CREATE TABLE FieldStudy (
	uID INT NOT NULL,
	field TEXT NOT NULL,
	enrollRate FLOAT NOT NULL,
	mobility TEXT,
	PRIMARY KEY (uID, field, mobility),
    FOREIGN KEY (uID) REFERENCES EducationLevel(uID)
);

-- Employment rate in different institution sectors.
CREATE TABLE EarnType (
	uID INT NOT NULL,
	type TEXT NOT NULL,
	rate FLOAT NOT NULL,
    year INT, -- check this !!!!!!!!!!!!!!!!!
	PRIMARY KEY (uID, type, year),
    FOREIGN KEY (uID) REFERENCES EducationLevel(uID)
);


