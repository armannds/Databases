/*
view: StudentsFollowing
For all students, their names and the programmes and branch they are following.
*/
CREATE VIEW StudentsFollowing AS
SELECT id, name, programme, branch
FROM Students
ORDER BY id;

/*
view:FinishedCourses 
For all students, all finished courses, along with their grades(grade: 'U',3,4 or 5)
*/
CREATE VIEW FinishedCourses AS
SELECT S.id, S.name, F.course, F.grade
FROM Finished F, Students S
WHERE F.student = S.id
ORDER BY S.id;

/*
view:Registration
All registered and waiting students for all courses, along with their waiting status ('registered' or 'waiting').
*/
CREATE VIEW Registration AS
SELECT S.id, S.name, R.course, 'registered' AS status
FROM Students S, RegisteredTo R
WHERE S.id = R.student
UNION
SELECT S.id, S.name, I.limitedCourse, 'waiting' AS status
FROM Students S, InQueue I
WHERE S.id = I.student;


/*
View: PassedCourses
For all students, all passed courses, i.e. courses finished with a grade other than 'U'. T
This view is intended as a helper view towards the PathToGraduation view, and will not be directly used by your application.
*/
CREATE VIEW PassedCourses AS
SELECT S.id, S.name, F.course, F.grade
FROM Students S, Finished F
WHERE S.id = F.student AND F.grade NOT IN ('U')
ORDER BY S.id; 

/*
View: UnreadMandatory
For all students, the mandatory courses (branch and programme) they have not yet passed.
*/
CREATE VIEW UnreadMandatory AS
SELECT S.id, S.name, S.branch, S.programme, M.course, C.name AS coursename
FROM Students S, HasMandatory M, Courses C
WHERE S.programme = M.programme AND M.course = C.code AND (S.id, M.course) NOT IN (SELECT id, course FROM PassedCourses)
UNION
SELECT S.id, S.name, S.branch, S.programme, B.course, C.name
FROM Students S, BranchMandatory B, Courses C
WHERE S.branch = B.branch AND S.programme = B.programme AND B.course = C.code AND (S.id, B.course) NOT IN (SELECT id, course FROM PassedCourses);

CREATE VIEW CountUnreadMandatory AS
SELECT S.id, COUNT(U.coursename) AS nrUnreadMand
FROM Students S, UnreadMandatory U
WHERE S.id = U.id
GROUP BY S.id;

/*
View: PathToGraduation
For all students, their path to graduation, i.e. a view with columns for

    the number of credits they have passed.
    the number of branch-specific mandatory and recommended credits they have passed.
    the number of mandatory courses they have yet to pass (branch or programme).
    the number of credits they have passed in courses that are classified as math courses.
    the number of credits they have passed courses that are classified as research courses.
    the number of credits they have passed courses that are classified as seminar courses.
    whether or not they qualify for graduation.

*/
CREATE VIEW CountPassedCredits AS
SELECT P.id, SUM(C.credits) AS passedCredits
FROM PassedCourses P, Courses C
WHERE P.course = C.code
GROUP BY P.id
ORDER BY P.id;

/*Helper VIEW - Finds all mandatory and recommended courses for each branch*/
CREATE VIEW FindMandRecCourses AS
SELECT S.id, B.course, C.credits
FROM Students S, BranchMandatory B, Courses C
WHERE S.programme = B.programme AND S.branch = B.branch AND B.course = C.code 
UNION
SELECT S.id, R.course, C.credits
FROM Students S, HasRecommended R, Courses C
WHERE S.programme = R.programme AND S.branch = R.branch AND R.course = C.code;

CREATE VIEW CountMandRecCredPassed AS
SELECT S.id, SUM(F.credits) AS passedMandRecCredits
FROM Students S, FindMandRecCourses F
WHERE S.id = F.id AND (S.id, F.course) IN (SELECT id, course FROM PassedCourses)
GROUP BY S.id;

CREATE VIEW CountMathCourses AS
SELECT S.id, SUM(C.credits) AS nrMathCredits
FROM Students S, Courses C
WHERE (S.id, C.code) IN (SELECT id, course FROM PassedCourses) AND C.code IN (SELECT T.course FROM TypeOf T WHERE type = 'Mathematical Course')
GROUP BY S.id;

CREATE VIEW CountResearchCourses AS
SELECT S.id, SUM(C.credits) AS nrResCredits
FROM Students S, Courses C
WHERE (S.id, C.code) IN (SELECT id, course FROM PassedCourses) AND C.code IN (SELECT T.course FROM TypeOf T WHERE type = 'Research Course')
GROUP BY S.id;	  	   

CREATE VIEW CountSeminarCourses AS
SELECT S.id, COUNT(C.code) AS nrSemCourses
FROM Students S, Courses C
WHERE (S.id, C.code) IN (SELECT id, course FROM PassedCourses) AND C.code IN (SELECT T.course FROM TypeOf T WHERE type = 'Seminar Course')
GROUP BY S.id;

/*Helper VIEW - Counts mandatory courses for a programme that a student has finished*/
CREATE VIEW FinishedMandatory AS
SELECT S.id, COUNT(M.course) AS nrFinishedMandatory
FROM Students S, HasMandatory M
WHERE S.programme = M.programme AND (S.id, M.course) IN (SELECT id, course FROM PassedCourses)
GROUP BY S.id;

/*Helper VIEW - Counts mandatory courses for a programme*/
CREATE VIEW CountProgrammeMand AS
SELECT P.name, COUNT(M.course) AS nrMandCourses
FROM Programmes P, HasMandatory M
WHERE P.name = M.programme
GROUP BY P.name;

/*Helper VIEW - counts mandatory courses for a branch*/
CREATE VIEW CountBranchMand AS
SELECT A.name, A.programme, COUNT(B.Course) AS nrMandBrCourses
FROM Branches A, BranchMandatory B
WHERE A.programme = B.programme AND A.name = B.branch
GROUP BY (A.name, A.programme);

/*Helper VIEW - counts mandatory courses for a branch that a student has finished*/
CREATE VIEW FinishedBranchMandatory AS
SELECT S.id, COUNT(B.course) AS nrFinishedBrMandatory
FROM Students S, BranchMandatory B
WHERE S.programme = B.programme AND S.branch = B.branch AND (S.id, B.course) IN (SELECT id, course FROM PassedCourses)
GROUP BY S.id;

/*Using case statement*/
CREATE VIEW CheckGraduation AS
(SELECT S.id,
(CASE 
WHEN ((SELECT A.nrMandCourses FROM CountProgrammeMand A WHERE S.programme = A.name) = (SELECT B.nrFinishedMandatory FROM FinishedMandatory B WHERE S.id = B.id)) AND 
((SELECT C.nrMandBrCourses FROM CountBranchMand C WHERE S.branch = C.name AND S.programme = C.programme) = (SELECT D.nrFinishedBrMandatory FROM FinishedBranchMandatory D WHERE S.id = D.id)) AND
((SELECT E.passedMandRecCredits FROM CountMandRecCredPassed E WHERE S.id = E.id) >= 10) AND 
((SELECT F.nrMathCredits FROM CountMathCourses F WHERE S.id = F.id) >= 20) AND
((SELECT G.nrResCredits FROM CountResearchCourses G WHERE S.id = G.id) >= 10) AND
((SELECT H.nrSemCourses FROM CountSeminarCourses H WHERE S.id = H.id) > 0) 
THEN 
'Yes' 
ELSE 
'No'
END) "status"
FROM Students S);

/*Functions that checks if a student is qualified for graduation*/
CREATE FUNCTION CheckGraduation(IN id CHAR(10)) RETURNS CHAR(3)
BEGIN
IF ((SELECT A.nrMandCourse FROM CountProgrammeMand A WHERE id = A.id) = (SELECT B.nrFinishedMandatory FROM FinishedMandatory B WHERE id = B.id))
AND IF ((SELECT C.nrMandBrCourses FROM CountBranchMand C WHERE id = C.id) = (SELECT D.nrFinishedBrMandatory FROM FinishedBrMandatory D WHERE id = D.id))
AND IF ((SELECT E.passedMandRecCredits FROM CountMandRecCredPassed E WHERE id = E.id) >= 10)
AND IF ((SELECT F.nrMathCredits FROM CountMathCourses F WHERE id = F.id) >= 20)
AND IF ((SELECT G.nrResCredits FROM CountResearchCourses G WHERE id = G.id) >= 10)
AND IF ((SELECT H.nrSemCourses FROM CountSeminarCourses H WHERE id = H.id) > 0)
THEN RETURN 'YES';
ELSE RETURN 'NO';
END IF;
END;
  
CREATE VIEW PathToGraduation AS
SELECT S.id, C.passedCredits, B.passedMandRecCredits, U.nrUnreadMand, M.nrMathCredits, R.nrResCredits, X.nrSemCredits, CheckGraduation(S.id)
FROM Students S, CountPassedCredits C, CountMandRecCredPassed B, CountUnreadMandatory U, CountMathCourses M, CountResearchCourses R, CountSeminarCourses X
WHERE S.id = C.id AND S.id = B.id AND S.id = U.id AND S.id = M.id AND S.id = R.id AND S.id = X.id
GROUP BY S.id, C.passedCredits, B.passedMandRecCredits, U.nrUnreadMand, M.nrMathCredits, R.nrResCredits, X.nrSemCredits;





