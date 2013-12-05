CREATE VIEW CourseQueuePositions AS
SELECT I.student, I.limitedCourse, ROW_NUMBER() OVER (PARTITION BY limitedCourse ORDER BY timeRegistered ASC) AS position
FROM InQueue I;

CREATE OR REPLACE TRIGGER CourseRegistration
INSTEAD OF INSERT ON Registration
REFERENCING NEW AS new
FOR EACH ROW
DECLARE
maxNumStudents Int;
currentNumStudents INT;
limitedNum INT;
alreadyRegisteredTo INT;
alreadyFinished INT;
countPrequisuites INT;
countStudentsFinishedPrereq INT;
BEGIN
   SELECT NVL(COUNT(*),0) INTO alreadyRegisteredTo FROM RegisteredTo R WHERE R.student = :new.id AND R.course = :new.course;
   SELECT NVL(COUNT(*),0) INTO alreadyFinished FROM PassedCourses P WHERE P.id = :new.id AND P.course = :new.course;
   IF (alreadyRegisteredTo = 0) AND (alreadyFinished = 0) THEN --Check if the student has already registered or already finished the course
   BEGIN
   	   SELECT NVL(COUNT(*),0) INTO countPrequisuites FROM HasPrerequisites P WHERE P.course = :new.course;
   	   SELECT NVL(COUNT(*),0) INTO countStudentsFinishedPrereq FROM PassedCourses P WHERE P.id = :new.id AND P.course IN (SELECT prereqCourse FROM HasPrerequisites WHERE course = :new.course);
   	   IF (countPrequisuites - countStudentsFinishedPrereq = 0) THEN --Check if the student has finished all prerequisites
   	   BEGIN
		   SELECT COUNT (*) INTO limitedNum FROM LimitedCourses WHERE course = :new.course;
		   IF limitedNum > 0 THEN --limited course
		      BEGIN
		      SELECT nrStudents INTO maxNumStudents FROM LimitedCourses WHERE course = :new.course;
		      SELECT COUNT (*) INTO currentNumStudents FROM RegisteredTo WHERE course = :new.course;
		      IF (currentNumStudents < maxNumStudents) THEN 
	          	INSERT INTO RegisteredTo VALUES (:new.id, :new.course);
	      	  ELSE 
	         	INSERT INTO InQueue VALUES (:new.id, :new.course, CURRENT_TIMESTAMP);
	      	  END IF;
	      	  END;
	       ELSE
	       	  INSERT INTO RegisteredTo VALUES (:new.id, :new.course);
		   END IF;
	   END;
	   ELSE
	   	   RAISE_APPLICATION_ERROR(10002, 'The student has not finished all prerequisites for chosen course');	
	   END IF;
   END;
   ELSE
   	   RAISE_APPLICATION_ERROR(10001, 'The student is already registered to chosen course or has already finished it');
   END IF;
END;

CREATE OR REPLACE TRIGGER CourseUnregistration
INSTEAD OF DELETE ON Registration
REFERENCING OLD AS old
FOR EACH ROW
DECLARE
firstStuInQueue Students.id%TYPE; --CHAR(10)
waitingNum INT;
BEGIN
   DELETE FROM RegisteredTo R WHERE R.student = :old.id AND R.course = :old.course;
   SELECT COUNT (student) INTO waitingNum FROM InQueue I WHERE I.limitedCourse = :old.course;
   IF waitingNum > 0 THEN --there are waiting students
      SELECT student INTO firstStuInQueue FROM CourseQueuePositions Q WHERE Q.limitedCourse = :old.course AND Q.position = (SELECT MIN(position) FROM CourseQueuePositions WHERE Q.limitedCourse = :old.course);
      INSERT INTO RegisteredTo VALUES (firstStuInQueue, :old.course); 
      DELETE FROM CourseQueuePositions Q WHERE Q.student = :old.id AND Q.limitedCourse = :old.course;
      UPDATE Registration R set status = 'registered' WHERE R.id = firstStuInQueue AND R.course = :old.course; --update the priority if necessary
   END IF;
END;
