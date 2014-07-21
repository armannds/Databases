CREATE OR REPLACE VIEW CourseQueuePositions AS
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
alreadyInQueue INT;
countPrequisuites INT;
countStudentsFinishedPrereq INT;
BEGIN
   SELECT COUNT(*) INTO alreadyRegisteredTo FROM RegisteredTo R WHERE R.student = :new.id AND R.course = :new.course;
   SELECT COUNT(*) INTO alreadyFinished FROM PassedCourses P WHERE P.id = :new.id AND P.course = :new.course;
   SELECT COUNT(*) INTO alreadyInQueue FROM InQueue I WHERE I.student = :new.id AND I.limitedCourse = :new.course;
   IF (alreadyRegisteredTo = 0) AND (alreadyFinished = 0) AND (alreadyInQueue = 0) THEN --Check if the student has already registered, already finished the course or is already in the queue
   BEGIN
   	   SELECT COUNT(*) INTO countPrequisuites FROM HasPrerequisites P WHERE P.course = :new.course;
   	   SELECT COUNT(*) INTO countStudentsFinishedPrereq FROM PassedCourses P WHERE P.id = :new.id AND P.course IN (SELECT prereqCourse FROM HasPrerequisites WHERE course = :new.course);
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
	   	   RAISE_APPLICATION_ERROR(-20002, 'Student does not have all prerequisites for this course');	
	   END IF;
   END;
   ELSE
   	   RAISE_APPLICATION_ERROR(-20001, 'Student is already registered for this course or has already finished it');
   END IF;
END;

CREATE OR REPLACE TRIGGER CourseUnregistration
INSTEAD OF DELETE ON Registration
REFERENCING OLD AS old
FOR EACH ROW
DECLARE
firstStuInQueue Students.id%TYPE; 
waitingNum INT;
BEGIN 
IF :old.status = 'registered' THEN
   DELETE FROM RegisteredTo R WHERE R.student = :old.id AND R.course = :old.course;
   SELECT COUNT (student) INTO waitingNum FROM InQueue I WHERE I.limitedCourse = :old.course;
   IF waitingNum > 0 THEN
      BEGIN --there are waiting students
      SELECT student INTO firstStuInQueue FROM CourseQueuePositions Q WHERE Q.limitedCourse = :old.course AND Q.position = 1;
      INSERT INTO RegisteredTo VALUES (firstStuInQueue, :old.course); 
      DELETE FROM InQueue I WHERE I.student = firstStuInQueue AND I.limitedCourse = :old.course;
      END;
   END IF;
ELSE  --Assumption that a student is either registered in a course or waiting to be registered
   DELETE FROM InQueue I WHERE I.student = :old.id AND I.limitedCourse = :old.course;
END IF;
END;


