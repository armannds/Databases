CREATE VIEW CourseQueuePositions AS
SELECT I.student, I.limitedCourse, ROW_NUMBER() OVER (PARTITION BY limitedCourse ORDER BY timeRegistered ASC) AS position
FROM InQueue I;



CREATE OR REPLACE TRIGGER CourseRegistration
INSTEAD OF INSERT ON Registration
REFERENCING NEW AS new
FOR EACH ROW
DECLARE
maxNum Int;
currentNum INT;
limitedNum INT;
BEGIN
   SELECT COUNT (*) INTO limitedNum FROM LimitedCourses WHERE code = :new.course;
   IF limited > 0 THEN
   	  BEGIN 
      SELECT nrStudents INTO maxNum FROM LimitedCourses WHERE code = :new.course;
      SELECT COUNT (*) INTO currentNum
      FROM RegisteredTo
      WHERE course = :new.course;
      --Check if the student is eligible to register for the course
      IF ((:new.id, :new.course) NOT IN (SELECT student, course FROM PassedCourses)) AND ((SELECT prereqCourse FROM HasPrequisites WHERE course = :new.course) IN (SELECT course FROM PassedCourses WHERE id = new.id))
	      IF currentNum < maxNum THEN 
	         INSERT INTO RegisteredTo VALUES (:new.id, :new.course);
	      ELSE 
	         INSERT INTO InQueue VALUES (:new.id, :new.course, CURDATE());
	      END IF;
      ELSE
      	RAISE_APPLICATION_ERROR(10001, 'The student is not eligible for this course');
      END IF;
      END;
   ELSE 
      INSERT INTO RegisteredTo VALUES (:new.id, :new.course);
   END IF;
END;