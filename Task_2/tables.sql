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

CREATE TABLE LimitedCourses
(
	course CHAR(6) REFERENCES Courses (code),
	nrStudents INT,
	PRIMARY KEY (code)
);

CREATE TABLE CourseTypes
(
	type VARCHAR(255) PRIMARY KEY
);

CREATE TABLE TypeOf
(
	course CHAR(6),
	type VARCHAR(255),
	FOREIGN KEY (course) REFERENCES Courses (code),
	FOREIGN KEY (type) REFERENCES CourseTypes (type),
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

/*TODO add conditions for on update and on delete*/
CREATE TABLE HasMandatory
(
	programme VARCHAR(255),
	course CHAR(6),
	FOREIGN KEY (programme) REFERENCES Programmes (name),
	FOREIGN KEY (course) REFERENCES Courses (code),
); 

/*TODO add conditions for on update and on delete*/
CREATE TABLE BrancMandatory
(
	branch VARCHAR(255),
	programme VARCHAR(255),
	course CHAR(6),
	FOREIGN KEY (branch) REFERENCES Branches (name),
	FOREIGN KEY (programme) REFERENCES Branches (programme),
	FOREIGN KEY (course) REFERENCES Courses (code),
);

CREATE TABLE HasRecommended
(
	branch VARCHAR(255),
	programme VARCHAR(255),
	course CHAR(6),
	FOREIGN KEY (branch) REFERENCES Branches (name),
	FOREIGN KEY (programme) REFERENCES Branches (programme),
	FOREIGN KEY (course) REFERENCES Courses (code),	
);

CREATE TABLE HasPrerequisites
(
	course CHAR(6),
	prereqCourse CHAR(6),
	FOREIGN KEY (course) REFERENCES Courses (code),
	FOREIGN KEY (prereqCourse) REFERENCES Courses (code),
);

CREATE TABLE RegisteredTo
(
	student CHAR(10),
	course CHAR(6),
	FOREIGN KEY (student) REFERENCES Students (id),
	FOREIGN KEY (course) REFERENCES Courses (code),		
);

CREATE TABLE Finished
(
	student CHAR(10),
	course CHAR(6),
	grade CHAR(1),
	FOREIGN KEY (student) REFERENCES Students (id),
	FOREIGN KEY (course) REFERENCES Courses (code),
);

CREATE TABLE InQueue
(
	student CHAR(10),
	limitedCourse CHAR(6),
	timeRegistered DATETIME,
	FOREIGN KEY (student) REFERENCES Students (id),
	FOREIGN KEY (course) REFERENCES LimitedCourses (code),
);