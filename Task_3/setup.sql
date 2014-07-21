begin
for c in (select table_name from user_tables) loop
execute immediate ('drop table '||c.table_name||' cascade constraints');
end loop;
end;
/
begin
for c in (select * from user_objects) loop
execute immediate ('drop '||c.object_type||' '||c.object_name);
end loop;
end;
/

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
	CONSTRAINT register PRIMARY KEY (student, course),
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
	timeRegistered TIMESTAMP,
	CONSTRAINT inqueue PRIMARY KEY (student, limitedCourse),
	FOREIGN KEY (student) REFERENCES Students (id),
	FOREIGN KEY (limitedCourse) REFERENCES LimitedCourses (course)
);

INSERT INTO Departments 
	VALUES ('Department of Computing Science', 'DCSE');
INSERT INTO Departments
	VALUES ('Automotive Engineering Department', 'DAME');
INSERT INTO Departments		   
	VALUES ('Signals and Systems Department', 'DSS');
INSERT INTO Departments
	VALUES ('Civil and Environmental Engineering Department', 'DCEE');

INSERT INTO Programmes
	VALUES ('Computer Science and Engineering Programme', 'CSEP');
INSERT INTO Programmes
	VALUES ('Automotive Engineering Programme', 'AEP');
INSERT INTO Programmes
	VALUES ('Signals and Systems Programme', 'SSP');
INSERT INTO Programmes
	VALUES ('Civil Engineering Programme', 'CEP');
INSERT INTO Programmes
	VALUES ('Environmental Engineering Programme', 'EEP');

INSERT INTO Branches 
	VALUES ('Computer Science','Computer Science and Engineering Programme');
INSERT INTO Branches 
	VALUES ('Software Engineering','Computer Science and Engineering Programme');
INSERT INTO Branches 
	VALUES ('Interaction Design','Computer Science and Engineering Programme');
INSERT INTO Branches
	VALUES('Mechatronics','Automotive Engineering Programme');
INSERT INTO Branches
	VALUES('Interaction Design','Automotive Engineering Programme');
INSERT INTO Branches
	VALUES('Biomedical Engineering','Signals and Systems Programme');
INSERT INTO Branches
	VALUES('Communication Engineering','Signals and Systems Programme');
INSERT INTO Branches
	VALUES('Infrastructure and Environmental Engineering','Environmental Engineering Programme');
INSERT INTO Branches
	VALUES('Architecture and Urban Design','Civil Engineering Programme');

INSERT INTO Courses
	VALUES ('TDA001','Requirement Engineering',7.5,'Department of Computing Science');
INSERT INTO Courses
	VALUES ('TDA002','Databases',7.5,'Department of Computing Science');
INSERT INTO Courses
	VALUES ('TDA003','Android Development',7.5,'Department of Computing Science');
INSERT INTO Courses
	VALUES ('TDA004','Vehicle Dynamics',7.5,'Automotive Engineering Department');
INSERT INTO Courses
	VALUES ('TDA005','Traffic Safety',7.5,'Automotive Engineering Department');
INSERT INTO Courses
	VALUES ('TDA006','Internal Combustion Engines',7.5,'Automotive Engineering Department');
INSERT INTO Courses
	VALUES ('TDA007','eHealth',7.5,'Signals and Systems Department');
INSERT INTO Courses
	VALUES ('TDA008','Image Processing',7.5,'Signals and Systems Department');
INSERT INTO Courses
	VALUES ('TDA009','Applied Signal Processing',7.5,'Signals and Systems Department');
INSERT INTO Courses
	VALUES ('TDA010','Engineering Geology',7.5,'Civil and Environmental Engineering Department');
INSERT INTO Courses
	VALUES ('TDA011','Drinking Water Engineering',7.5,'Civil and Environmental Engineering Department');
INSERT INTO Courses
	VALUES ('TDA012','Environmental Analyses',7.5,'Civil and Environmental Engineering Department');
INSERT INTO Courses
	VALUES ('TDA013','Algorithms',7.5,'Department of Computing Science');
INSERT INTO Courses
	VALUES ('TDA014','Modeling and Simulation',7.5,'Signals and Systems Department');
INSERT INTO Courses
	VALUES ('TDA015','Image Analysis',7.5,'Signals and Systems Department');
INSERT INTO Courses
	VALUES ('TDA016','Project Management',7.5,'Department of Computing Science');
INSERT INTO Courses
	VALUES ('TDA017','Medicine for the Engineering',7.5,'Signals and Systems Department');
INSERT INTO Courses
	VALUES ('TDA018','Software Project Evolution',7.5,'Department of Computing Science');


INSERT INTO LimitedCourses
	VALUES ('TDA005', 60);
INSERT INTO LimitedCourses
	VALUES ('TDA008', 30);
INSERT INTO LimitedCourses
	VALUES ('TDA018', 3);


INSERT INTO CourseTypes
	VALUES ('Mathematical Course');
INSERT INTO CourseTypes
	VALUES ('Research Course');
INSERT INTO CourseTypes
	VALUES ('Seminar Course');


INSERT INTO TypeOf
	VALUES ('TDA004', 'Mathematical Course');
INSERT INTO TypeOf
	VALUES ('TDA007', 'Mathematical Course');
INSERT INTO TypeOf
	VALUES ('TDA011', 'Research Course');
INSERT INTO TypeOf
	VALUES ('TDA011', 'Seminar Course');
INSERT INTO TypeOf
	VALUES('TDA013','Mathematical Course');	
INSERT INTO TypeOf
	VALUES('TDA001','Research Course');	
INSERT INTO TypeOf
	VALUES('TDA002','Seminar Course');	
INSERT INTO TypeOf
	VALUES('TDA005','Mathematical Course');	


INSERT INTO Students
	VALUES ('100','Fredrik Nilsson','Communication Engineering','Signals and Systems Programme');
INSERT INTO Students
	VALUES ('101','Maria Andersson','Interaction Design','Computer Science and Engineering Programme');
INSERT INTO Students
	VALUES ('102','Jan Larsson','Biomedical Engineering','Signals and Systems Programme');
INSERT INTO Students
	VALUES ('103','Eva Margareta','Architecture and Urban Design','Civil Engineering Programme');
INSERT INTO Students
	VALUES ('104','Johan Lars Hansson','Interaction Design','Automotive Engineering Programme');
INSERT INTO Students
	VALUES ('105','Jack Bauer','Software Engineering','Computer Science and Engineering Programme');
INSERT INTO Students
	VALUES ('106','Emma Johansson','Software Engineering','Computer Science and Engineering Programme');

INSERT INTO HasProgrammes
	VALUES ('Department of Computing Science','Computer Science and Engineering Programme');
INSERT INTO HasProgrammes
	VALUES ('Automotive Engineering Department','Automotive Engineering Programme');
INSERT INTO HasProgrammes
	VALUES ('Signals and Systems Department','Signals and Systems Programme');
INSERT INTO HasProgrammes
	VALUES ('Civil and Environmental Engineering Department','Civil Engineering Programme');
INSERT INTO HasProgrammes
	VALUES ('Civil and Environmental Engineering Department','Environmental Engineering Programme');

INSERT INTO HasMandatory
	VALUES ('Signals and Systems Programme','TDA007');
INSERT INTO HasMandatory
	VALUES ('Civil Engineering Programme','TDA011');
INSERT INTO HasMandatory
	VALUES ('Computer Science and Engineering Programme','TDA013');

INSERT INTO BranchMandatory
	VALUES ('Biomedical Engineering','Signals and Systems Programme','TDA017');
INSERT INTO BranchMandatory
	VALUES ('Interaction Design','Automotive Engineering Programme','TDA006');
INSERT INTO BranchMandatory
	VALUES ('Software Engineering','Computer Science and Engineering Programme','TDA001');

INSERT INTO HasRecommended
	VALUES ('Biomedical Engineering','Signals and Systems Programme','TDA002');
INSERT INTO HasRecommended
	VALUES ('Software Engineering','Computer Science and Engineering Programme','TDA002');

INSERT INTO HasPrerequisites
	VALUES ('TDA011','TDA010');
INSERT INTO HasPrerequisites
	VALUES ('TDA003','TDA005');

INSERT INTO	RegisteredTo
	VALUES ('100','TDA006');
INSERT INTO	RegisteredTo
	VALUES ('103','TDA004');
INSERT INTO	RegisteredTo
	VALUES ('102','TDA012');
INSERT INTO	RegisteredTo
	VALUES ('104','TDA011');
INSERT INTO	RegisteredTo
	VALUES ('101','TDA018');
INSERT INTO	RegisteredTo
	VALUES ('102','TDA018');
INSERT INTO	RegisteredTo
	VALUES ('103','TDA018');	

INSERT INTO	Finished
	VALUES ('100','TDA001','3');
INSERT INTO	Finished
	VALUES ('103','TDA014','4');
INSERT INTO	Finished
	VALUES ('101','TDA003','5');
INSERT INTO	Finished
	VALUES ('104','TDA015','U');
INSERT INTO Finished
	VALUES ('102','TDA007','5');
INSERT INTO Finished
	VALUES ('105','TDA001','3');
INSERT INTO Finished
	VALUES ('105','TDA002','4');
INSERT INTO Finished
	VALUES ('104', 'TDA004','4');
INSERT INTO Finished
	VALUES ('104', 'TDA007','3');
INSERT INTO Finished
	VALUES ('106', 'TDA001','4');
INSERT INTO Finished
	VALUES ('106', 'TDA013','3');
INSERT INTO Finished
	VALUES ('106', 'TDA002','5');
INSERT INTO Finished
	VALUES ('106', 'TDA007','5');
INSERT INTO Finished
	VALUES ('106', 'TDA011','3');
INSERT INTO Finished
	VALUES ('106', 'TDA004','4');
INSERT INTO Finished
	VALUES ('106', 'TDA005','4');

INSERT INTO InQueue
VALUES ('100', 'TDA005', '2013-08-08');
INSERT INTO InQueue
VALUES ('101', 'TDA008', '2013-08-10');
INSERT INTO InQueue
VALUES ('102', 'TDA008', '2013-08-11');


CREATE OR REPLACE VIEW StudentsFollowing AS
SELECT id, name, programme, branch
FROM Students
ORDER BY id;

CREATE OR REPLACE VIEW FinishedCourses AS
SELECT S.id, S.name, F.course, C.name AS coursename, C.credits,  F.grade
FROM Finished F, Students S, Courses C
WHERE F.student = S.id AND C.code = F.course
ORDER BY S.id;

CREATE OR REPLACE VIEW Registration AS
SELECT S.id, S.name, R.course AS course, C.name AS coursename, 'registered' AS status
FROM Students S,RegisteredTo R, Courses C
WHERE S.id = R.student AND R.course = C.code
UNION
SELECT S.id, S.name, I.limitedCourse AS course, C.name AS coursename, 'waiting' AS status
FROM Students S, InQueue I, Courses C
WHERE S.id = I.student AND I.limitedCourse = C.code;

CREATE OR REPLACE VIEW PassedCourses AS
SELECT S.id, S.name, F.course, F.grade
FROM Students S, Finished F
WHERE S.id = F.student AND F.grade NOT IN ('U')
ORDER BY S.id; 

CREATE OR REPLACE VIEW UnreadMandatory AS
SELECT S.id, S.name, S.branch, S.programme, M.course, C.name AS coursename
FROM Students S, HasMandatory M, Courses C
WHERE S.programme = M.programme AND M.course = C.code AND (S.id, M.course) NOT IN (SELECT id, course FROM PassedCourses)
UNION
SELECT S.id, S.name, S.branch, S.programme, B.course, C.name
FROM Students S, BranchMandatory B, Courses C
WHERE S.branch = B.branch AND S.programme = B.programme AND B.course = C.code AND (S.id, B.course) NOT IN (SELECT id, course FROM PassedCourses);

CREATE OR REPLACE VIEW CountUnreadMandatory AS
SELECT S.id, COUNT(U.coursename) AS nrUnreadMand
FROM Students S, UnreadMandatory U
WHERE S.id = U.id
GROUP BY S.id;

CREATE OR REPLACE VIEW NumberPassedCredits AS
SELECT P.id, SUM(C.credits) AS passedCredits
FROM PassedCourses P, Courses C
WHERE P.course = C.code
GROUP BY P.id
ORDER BY P.id;

/*Helper VIEW - Finds all mandatory and recommended courses for each branch*/
CREATE OR REPLACE VIEW FindMandRecCourses AS
SELECT S.id, B.course, C.credits
FROM Students S, BranchMandatory B, Courses C
WHERE S.programme = B.programme AND S.branch = B.branch AND B.course = C.code 
UNION
SELECT S.id, R.course, C.credits
FROM Students S, HasRecommended R, Courses C
WHERE S.programme = R.programme AND S.branch = R.branch AND R.course = C.code;

CREATE OR REPLACE VIEW CountMandRecCredPassed AS
SELECT S.id, SUM(F.credits) AS passedMandRecCredits
FROM Students S, FindMandRecCourses F
WHERE S.id = F.id AND (S.id, F.course) IN (SELECT id, course FROM PassedCourses)
GROUP BY S.id;

CREATE OR REPLACE VIEW CountMathCourses AS
SELECT S.id, SUM(C.credits) AS nrMathCredits
FROM Students S, Courses C
WHERE (S.id, C.code) IN (SELECT id, course FROM PassedCourses) AND C.code IN (SELECT T.course FROM TypeOf T WHERE type = 'Mathematical Course')
GROUP BY S.id;

CREATE OR REPLACE VIEW CountResearchCourses AS
SELECT S.id, SUM(C.credits) AS nrResCredits
FROM Students S, Courses C
WHERE (S.id, C.code) IN (SELECT id, course FROM PassedCourses) AND C.code IN (SELECT T.course FROM TypeOf T WHERE type = 'Research Course')
GROUP BY S.id;	  	   

CREATE OR REPLACE VIEW NumberSeminarCourses AS
SELECT S.id, COUNT(C.code) AS nrSemCourses
FROM Students S, Courses C
WHERE (S.id, C.code) IN (SELECT id, course FROM PassedCourses) AND C.code IN (SELECT T.course FROM TypeOf T WHERE type = 'Seminar Course')
GROUP BY S.id;

/*Helper VIEW - Counts mandatory courses for a programme that a student has finished*/
CREATE OR REPLACE VIEW NumberFinishedMandatory AS
SELECT S.id, COUNT(M.course) AS nrFinishedMandatory
FROM Students S, HasMandatory M
WHERE S.programme = M.programme AND (S.id, M.course) IN (SELECT id, course FROM PassedCourses)
GROUP BY S.id;

/*Helper VIEW - Counts mandatory courses for a programme*/
CREATE OR REPLACE VIEW NumberProgrammeMand AS
SELECT P.name, COUNT(M.course) AS nrMandCourses
FROM Programmes P, HasMandatory M
WHERE P.name = M.programme
GROUP BY P.name;

/*Helper VIEW - counts mandatory courses for a branch*/
CREATE OR REPLACE VIEW NumberBranchMand AS
SELECT A.name, A.programme, COUNT(B.Course) AS nrMandBrCourses
FROM Branches A, BranchMandatory B
WHERE A.programme = B.programme AND A.name = B.branch
GROUP BY (A.name, A.programme);

/*Helper VIEW - counts mandatory courses for a branch that a student has finished*/
CREATE OR REPLACE VIEW FinishedBranchMandatory AS
SELECT S.id, COUNT(B.course) AS nrFinishedBrMandatory
FROM Students S, BranchMandatory B
WHERE S.programme = B.programme AND S.branch = B.branch AND (S.id, B.course) IN (SELECT id, course FROM PassedCourses)
GROUP BY S.id;

CREATE OR REPLACE VIEW CheckIfValidForGraduation AS
(SELECT S.id,
(CASE 
WHEN ((SELECT A.nrMandCourses FROM NumberProgrammeMand A WHERE S.programme = A.name) = (SELECT B.nrFinishedMandatory FROM NumberFinishedMandatory B WHERE S.id = B.id)) AND 
((SELECT C.nrMandBrCourses FROM NumberBranchMand C WHERE S.branch = C.name AND S.programme = C.programme) = (SELECT D.nrFinishedBrMandatory FROM FinishedBranchMandatory D WHERE S.id = D.id)) AND
((SELECT E.passedMandRecCredits FROM CountMandRecCredPassed E WHERE S.id = E.id) >= 10) AND 
((SELECT F.nrMathCredits FROM CountMathCourses F WHERE S.id = F.id) >= 20) AND
((SELECT G.nrResCredits FROM CountResearchCourses G WHERE S.id = G.id) >= 10) AND
((SELECT H.nrSemCourses FROM NumberSeminarCourses H WHERE S.id = H.id) > 0) 
THEN 
'Yes' 
ELSE 
'No'
END) "status"
FROM Students S);
  
CREATE OR REPLACE VIEW PathToGraduation AS
SELECT S.id, NVL(C.passedCredits,0) AS passedCredits, NVL(B.passedMandRecCredits,0) AS passedMandRecCredits, 
	NVL(U.nrUnreadMand,0) AS nrUnreadMand, NVL(M.nrMathCredits,0) AS nrMathCredits, NVL(R.nrResCredits,0) AS nrResCredits, 
	NVL(X.nrSemCourses,0) AS nrSemCourses, G."status" AS status
FROM Students S
LEFT OUTER JOIN NumberPassedCredits C
ON S.id = C.id
LEFT OUTER JOIN CountMandRecCredPassed B
ON S.id = B.id
LEFT OUTER JOIN CountUnreadMandatory U
ON S.id = U.id
LEFT OUTER JOIN CountMathCourses M
ON S.id = M.id
LEFT OUTER JOIN CountResearchCourses R
ON S.id = R.id
LEFT OUTER JOIN NumberSeminarCourses X
ON S.id = X.id
LEFT OUTER JOIN CheckIfValidForGraduation  G
ON S.id = G.id;