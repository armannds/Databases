Views


CREATE VIEW view_name AS
SELECT column_name(s)
FROM table_name
WHERE condition

/*
view: StudentsFollowing
For all students, their names and the programmes and branch they are following.
*/
CREATE VIEW StudentsFollowing AS
SELECT name, programme, branch
FROM Students

/*
view:FinishedCourses 
For all students, all finished courses, along with their grades(grade: 'U',3,4 or 5)
*/
CREATE VIEW FinishedCourses AS
SELECT S.id, S.name, F.course, F.grade
FROM Finished F, Students S.
WHERE F.student = S.id

/*
view:Registration
All registered and waiting students for all courses, along with their waiting status ('registered' or 'waiting').
*/

CREATE VIEW Registration AS
SELECT S.id, 
FROM Students S, InQueue I, RegisteredTo R

/*
View: PassedCourses
For all students, all passed courses, i.e. courses finished with a grade other than 'U'. T
This view is intended as a helper view towards the PathToGraduation view, and will not be directly used by your application.
*/
CREATE VIEW PassedCourses AS
SELECT
FROM

/*
View: UnreadMandatory
For all students, the mandatory courses (branch and programme) they have not yet passed.
*/
CREATE View UndreadMandatory
SELECT
FROM

/*
View: PathToGraduation
For all students, their path to graduation, i.e. a view with columns for
*/








