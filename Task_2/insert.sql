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
