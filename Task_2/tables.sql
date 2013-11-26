CREATE TABLE Departments
(
	name VARCHAR(255) PRIMARY KEY NOT NULL,
	abbreviation CHAR(5)
);

CREATE TABLE Programmes
(
	name VARCHAR(255) PRIMARY KEY NOT NULL,
	abbreviation CHAR(5)
);

CREATE TABLE Branches
(
	name VARCHAR(255) NOT NULL,
	programme REFERENCES Programmes(name),
	PRIMARY KEY (name, programme)
);

CREATE TABLE Courses
(
	code CHAR(6) PRIMARY KEY,
	name VARCHAR(255),
	credits REAL,
	department REFERENCES Departments (name)
);

CREATE TABLE LimitedCourses
(
	course CHAR(6) REFERENCES Courses (code),
	nrStudents INT,
	PRIMARY KEY (course),
	CONSTRAINT chk_nrStudents CHECK (nrStudents >= 0)
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
	FOREIGN KEY (type) REFERENCES CourseTypes (type)
);

CREATE TABLE Students
(
	id CHAR(10) PRIMARY KEY,
	name VARCHAR(255),
	branch VARCHAR(255),
	programme VARCHAR(255),
	FOREIGN KEY (branch, programme) REFERENCES Branches (name, programme)
);

CREATE TABLE HasProgrammes
(
	department VARCHAR(255),
	programme VARCHAR(255),
	FOREIGN KEY (department) REFERENCES Departments (name),
	FOREIGN KEY (programme) REFERENCES Programmes (name)
); 

CREATE TABLE HasMandatory
(
	programme VARCHAR(255),
	course CHAR(6),
	FOREIGN KEY (programme) REFERENCES Programmes (name),
	FOREIGN KEY (course) REFERENCES Courses (code)
); 

CREATE TABLE BranchMandatory
(
	branch VARCHAR(255),
	programme VARCHAR(255),
	course CHAR(6),
	FOREIGN KEY (branch, programme) REFERENCES Branches (name, programme),
	FOREIGN KEY (course) REFERENCES Courses (code)
);

CREATE TABLE HasRecommended
(
	branch VARCHAR(255),
	programme VARCHAR(255),
	course CHAR(6),
	FOREIGN KEY (branch, programme) REFERENCES Branches (name, programme),
	FOREIGN KEY (course) REFERENCES Courses (code)	
);

CREATE TABLE HasPrerequisites
(
	course CHAR(6),
	prereqCourse CHAR(6),
	FOREIGN KEY (course) REFERENCES Courses (code),
	FOREIGN KEY (prereqCourse) REFERENCES Courses (code)
);

CREATE TABLE RegisteredTo
(
	student CHAR(10),
	course CHAR(6),
	FOREIGN KEY (student) REFERENCES Students (id),
	FOREIGN KEY (course) REFERENCES Courses (code)
);

CREATE TABLE Finished
(
	student CHAR(10),
	course CHAR(6),
	grade CHAR(1),
	FOREIGN KEY (student) REFERENCES Students (id),
	FOREIGN KEY (course) REFERENCES Courses (code),
	CONSTRAINT chk_grade CHECK (grade IN ('U',3,4,5))
);

CREATE TABLE InQueue
(
	student CHAR(10),
	limitedCourse CHAR(6),
	timeRegistered DATE,
	FOREIGN KEY (student) REFERENCES Students (id),
	FOREIGN KEY (limitedCourse) REFERENCES LimitedCourses (course)
);