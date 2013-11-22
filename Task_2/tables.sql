CREATE TABLE Departments
(
	name VARCHAR(255) PRIMARY KEY,
	abbreviation CHAR(5)
);

CREATE TABLE Programmes
(
	name VARCHAR(255) PRIMARY KEY,
	abbreviation CHAR(5)
);

/*TODO Er eitthvað leiðinlegt, on delete and on update skoða betur*/
CREATE TABLE Branches
(
	name VARCHAR(255) PRIMARY KEY,
	programme VARCHAR(255),
	CONSTRAINT ProgrammeExists
		FOREIGN KEY (programme) REFERENCES Programmes(name)
			ON DELETE SET NULL
			ON UPDATE CASCADE
);

/*TODO Sama hér, skoða betur on delete og on update*/
CREATE TABLE Courses
(
	code CHAR(6) PRIMARY KEY,
	name VARCHAR(255),
	credits CHAR(3),
	department VARCHAR(255) REFERENCES Departments (name)
			ON DELETE SET NULL
			ON UPDATE CASCADE
);

CREATE TABLE CourseTypes
(
	type VARCHAR(255) PRIMARY KEY
);

CREATE TABLE Students
(
	id CHAR(10) PRIMARY KEY,
	name TEXT,
	branch VARCHAR(255) REFERENCES Branches (name),
	programme VARCHAR(255) REFERENCES Branches (programme),
);

/*TODO add conditions for on update and on delete*/
CREATE TABLE HasProgrammes
(
	department VARCHAR(255),
	programme VARCHAR(255),
	FOREIGN KEY (department) REFERENCES Departments (name),
	FOREIGN KEY (programme) REFERENCES Programmes (name),
);  