
CREATE OR REPLACE VIEW StudentsFollowing AS
SELECT id, name, programme, branch
FROM Students
ORDER BY id;

CREATE OR REPLACE VIEW FinishedCourses AS
SELECT S.id, S.name, F.course, F.grade
FROM Finished F, Students S
WHERE F.student = S.id
ORDER BY S.id;

CREATE OR REPLACE VIEW Registration AS
SELECT S.id, S.name, R.course, 'registered' AS status
FROM Students S, RegisteredTo R
WHERE S.id = R.student
UNION
SELECT S.id, S.name, I.limitedCourse, 'waiting' AS status
FROM Students S, InQueue I
WHERE S.id = I.student;

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
SELECT S.id, NVL(C.passedCredits,0) AS passedCredits, NVL(B.passedMandRecCredits,0) AS passedMandRecCredits, NVL(U.nrUnreadMand,0) AS nrUnreadMand, NVL(M.nrMathCredits,0) AS nrMathCredits, NVL(R.nrResCredits,0) AS nrResCredits, NVL(X.nrSemCourses,0) AS nrSemCourses, G."status"
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