import java.sql.*; // JDBC stuff.
import java.io.*;  // Reading user input.

public class StudentPortal {
	
	private static String pRegistered = "registered";
	/* This is the driving engine of the program. It parses the
	 * command-line arguments and calls the appropriate methods in
	 * the other classes.
	 *
	 * You should edit this file in two ways:
	 * 	1) 	Insert your database username and password (no @medic1!)
	 *		in the proper places.
	 *	2)	Implement the three functions getInformation, registerStudent
	 *		and unregisterStudent.
	 */
	public static void main(String[] args)
	{
		if (args.length == 1) {
			try {
				DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
				String url = "jdbc:oracle:thin:@tycho.ita.chalmers.se:1521/kingu.ita.chalmers.se";
				String userName = "htda357_034"; // Your username goes here!
				String password = "ArmannogRannveig"; // Your password goes here!
				Connection conn = DriverManager.getConnection(url,userName,password);

				String student = args[0]; // This is the identifier for the student.
				BufferedReader input = new BufferedReader(new InputStreamReader(System.in));
				System.out.println("Welcome!");
				while(true) {
					System.out.println("Please choose a mode of operation:");
					System.out.print("? > ");
					String mode = input.readLine();
					if ((new String("information")).startsWith(mode.toLowerCase())) {
						/* Information mode */
						getInformation(conn, student);
					} else if ((new String("register")).startsWith(mode.toLowerCase())) {
						/* Register student mode */
						System.out.print("Register for what course? > ");
						String course = input.readLine();
						registerStudent(conn, student, course);
					} else if ((new String("unregister")).startsWith(mode.toLowerCase())) {
						/* Unregister student mode */
						System.out.print("Unregister from what course? > ");
						String course = input.readLine();
						unregisterStudent(conn, student, course);
					} else if ((new String("quit")).startsWith(mode.toLowerCase())) {
						System.out.println("Goodbye!");
						break;
					} else {
						System.out.println("Unknown argument, please choose either " +
									 "information, register, unregister or quit!");
						continue;
					}
				}
				conn.close();
			} catch (SQLException e) {
				System.err.println(e);
				System.exit(2);
			} catch (IOException e) {
				System.err.println(e);
				System.exit(2);
			}
		} else {
			System.err.println("Wrong number of arguments");
			System.exit(3);
		}
	}

	static void getInformation(Connection conn, String student)
	{
		Statement stmt = null;
		
		try{
			stmt = conn.createStatement();
		}catch (SQLException e) {
            System.out.println("ERROR! Could not connect to database. Exiting applictaion");
            System.exit(1);
        }
		
		try{
        	ResultSet infoSet = stmt.executeQuery("SELECT name, programme, branch " + "FROM StudentsFollowing " +
    			" WHERE id = " + student);
        	
        	infoSet.next();
        	System.out.println("Information for student " + student);
	        System.out.println("-----------------------------------");
	        System.out.println("Name: " + infoSet.getString(1));
	        System.out.println("Programme: " + infoSet.getString(2));
	        System.out.println("Branch: " + infoSet.getString(3));

        }catch (SQLException e) {
            System.out.println("ERROR! Student information for "+ student +" does not exist. Exiting applictaion");
            return;
        }
	   
	    //Fetching information about finished courses.
	    try{
        	ResultSet infoSet = stmt.executeQuery("SELECT course, coursename, credits, grade " + " FROM FinishedCourses " 
        		+ " WHERE id = " + student);

        	System.out.println();
	        System.out.println("Finished courses (Name (code), credits: status): ");
	        while (infoSet.next()) {
		        System.out.println(infoSet.getString(2) + " (" + infoSet.getString(1) + "), " + infoSet.getString(3) + ": " 
	        + infoSet.getString(4));
		    }

        }catch (SQLException e) {
            System.out.println("ERROR! " + e.getMessage());
            return;
        }

	    //Fetching information about registered courses.
	    try{
        	ResultSet infoSet = stmt.executeQuery("SELECT course, coursename, C.credits, status " + " FROM Registration, Courses C"
        		 +" WHERE id = " + student + " AND status = '" + pRegistered + "'" + " AND C.code = course");

        	System.out.println();
        	System.out.println("Registered courses (Name (code), credits: status): ");
			while (infoSet.next()) {
	        	System.out.println(infoSet.getString(2) + " (" + infoSet.getString(1) + "), " + infoSet.getString(3) + ": " + 
			infoSet.getString(4));
	    	}

        }catch (SQLException e) {
            System.out.println("ERROR! " + e.getMessage());
            return;
        }
     
	    //Fetching information about waiting courses.
	    try{
        	ResultSet infoSet = stmt.executeQuery("SELECT course, coursename, C.credits, status, Q.position" 
    			+ " FROM Courses C, Registration, CourseQueuePositions Q" + " WHERE id = " + student + 
    			" AND status = 'waiting' AND C.code = course" + " AND Q.limitedCourse = course AND Q.student = " + student);

        	while (infoSet.next()) {
	        	System.out.println(infoSet.getString(2) + " (" + infoSet.getString(1) + "), " + infoSet.getString(3) + ": " + 
        			infoSet.getString(4) + " as nr " + infoSet.getString(5));
	    	}

        }catch (SQLException e) {
            System.out.println("ERROR! " + e.getMessage());
            System.exit(1);
        }

	    //List path to graduation
	    try{
        	ResultSet infoSet = stmt.executeQuery("SELECT nrSemCourses, nrMathCredits, nrResCredits, passedCredits, status" +
        		" FROM PathToGraduation" + " WHERE id = " + student);
        	
        	infoSet.next();
        	System.out.println();
	    	System.out.println("Seminar courses taken: " + infoSet.getString(1));
	    	System.out.println("Math credits taken: " + infoSet.getString(2));
	    	System.out.println("Research credits taken: " + infoSet.getString(3));
	    	System.out.println("Total credits taken: " + infoSet.getString(4));
	    	System.out.println("Fulfils the requriements for graduation: " + infoSet.getString(5));
	    	System.out.println();
        }catch (SQLException e) {
            System.out.println("ERROR! " + e.getMessage());
            return;
        }
    }

	static void registerStudent(Connection conn, String student, String course)
	{
		Statement stmt = null;
		try{
			stmt = conn.createStatement();
		}catch (SQLException e) {
            System.out.println("ERROR! Could not connect to database. Exiting applictaion");
            System.exit(1);
        }

        try{
        	stmt.executeUpdate("INSERT INTO Registration (id, course)" + " VALUES ('" + student + "', '" + course + "')" );	
        }catch (SQLException e) {
        	System.out.println("ERROR1! " + e.getMessage());
        	return;          
        }
        
        //Check to see where the student was registered
        try{
        	ResultSet mySet = stmt.executeQuery("SELECT status " + " FROM Registration " + " WHERE id = " + student + 
        		" AND course = '" + course + "'");

                        if (!mySet.next()) {
                                System.out.println("Failed to register for course.");
                                return;
                        } else {
                                // The course was not full 
                                if (pRegistered.equals(mySet.getString(1))) {
                                        System.out.println("You were successfully registered to course " + course + ".");
                                } else {
                                        // The course was full and the student was put in queue
                                        ResultSet subSet = stmt.executeQuery("SELECT position " + " FROM CourseQueuePositions " 
                                        	+ " WHERE student = '" + student + "' AND limitedCourse = '" + course + "'");
                                        subSet.next();
                                        System.out.println("The course was full and you have been put in a waiting queue for" +
                                        	" the course. Your number in the queue is: " + subSet.getString(1));
                                }                                
                        }

        }catch (SQLException e) {
        	System.out.println("ERROR2! " + e.getMessage());
        	return;
        } 

	}

	static void unregisterStudent(Connection conn, String student, String course)
	{
		Statement stmt = null;
		try{
			stmt = conn.createStatement();
		}catch (SQLException e) {
            System.out.println("ERROR! Could not connect to database. Exiting applictaion");
            System.exit(1);
        }
		
		try{
			//Check if the student is registered to a course
			ResultSet mySet = stmt.executeQuery("SELECT * " + " FROM Registration" + " WHERE id = " + student + 
				" AND course = '" + course + "'");
			if(!mySet.next()){
				System.out.println("You can not unregister from a course that you are not registered to!");
				return;
			}else{
				try{
					stmt.executeUpdate("DELETE FROM Registration " + " WHERE id = " + student + 
						" AND course = '" + course + "'");
				}catch (SQLException e) {
					System.out.println("ERROR1! " + e.getMessage());
					return;
				}
			}
		}catch (SQLException e) {
            System.out.println("ERROR2! " + e.getMessage());
            return;
        }
		//Check if student was successfully unregistered from a course
		
		try{
			ResultSet mySet = stmt.executeQuery("SELECT * " + " FROM Registration" + " WHERE id = " + student + 
				" AND course = '" + course + "'");
			if(mySet.next()){ 
				System.out.println("Failed to unregister student from the course");
				return;
			}else{
				System.out.println("The student was successfully unregistered from the course");
			}
		}
		catch (SQLException e) {
			System.out.println("ERROR3! " + e.getMessage());
			return;
		}
		
	}
}
