/* Student registers to a course that has limited number of students(Max 3 students) - OK */
INSERT INTO Registration (id, course) VALUES ('101','TDA018');
INSERT INTO Registration (id, course) VALUES ('102','TDA018');
INSERT INTO Registration (id, course) VALUES ('103','TDA018');

/* Student registers to a course that is full. This students has to wait in a queue. - OK- student is now in table InQueue  */
INSERT INTO Registration (id, course) VALUES ('104','TDA018');

/* Student drops a course that has limited number of students. Another student that is in a waiting list for this course gets registrated instead*/
DELETE FROM Registration WHERE id = '103' AND course = 'TDA018';

/*A student tries to register for a course that he has already passed. He should not be able to register - Error message will appear-ok*/
INSERT INTO Registration (id, course) VALUES ('100','TDA001');

/* A Student that has not finished the prerequisites tries to register for the limited course - error message will appear - ok */
INSERT INTO Registration (id, course) VALUES ('100','TDA019');

/* A Student that has finished the prerequisites for a course can register to the course - ok */
INSERT INTO Registration (id, course) VALUES ('103','TDA019');

/* A Student tries to register to a course he is already in - error message will appear*/
INSERT INTO Registration (id, course) VALUES ('101','TDA018');