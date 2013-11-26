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
WHERE S.id = I.student


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
CREATE VIEW UndreadMandatory AS
SELECT S.id, S.name, S.branch, S.programme, M.course, C.name AS coursename
FROM Students S, HasMandatory M, Courses C
WHERE S.programme = M.programme AND M.course = C.code AND (S.id, M.course) NOT IN (SELECT id, course FROM PassedCourses)
UNION
SELECT S.id, S.name, S.branch, S.programme, B.course, C.name
FROM Students S, BranchMandatory B, Courses C
WHERE S.branch = B.branch AND S.programme = B.programme AND B.course = C.code AND (S.id, B.course) NOT IN (SELECT id, course FROM PassedCourses);
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

#Helper VIEW
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
WHERE (S.id, C.code) IN (SELECT id, course FROM PassedCourses) AND C.code IN (SELECT T.course FROM TypeOf T WHERE type= 'Mathematical Course')
GROUP BY S.id;

CREATE VIEW CountResearchCourses AS
SELECT S.id, SUM(C.credits) AS nrResCredits
FROM Students S, Courses C
WHERE (S.id, C.code) IN (SELECT id, course FROM PassedCourses) AND C.code IN (SELECT T.course FROM TypeOf T WHERE type= 'Research Course')
GROUP BY S.id;	  	   

CREATE VIEW CountSeminarCourses AS
SELECT S.id, SUM(C.credits) AS nrSemCredits
FROM Students S, Courses C
WHERE (S.id, C.code) IN (SELECT id, course FROM PassedCourses) AND C.code IN (SELECT T.course FROM TypeOf T WHERE type= 'Seminar Course')
GROUP BY S.id;






