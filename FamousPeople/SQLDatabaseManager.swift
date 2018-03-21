import UIKit
import SQLite3

class SQLDatabaseManager: NSObject {
    
    // MARK: Opening Database
    
    // Ability to connect to database. Referred to as 'opening' the database
    /*
    1. Create a new property that will be a pointer to the database once we've opened it.
    2. Define a path to a database file in the app's documents directory. This file doesn't yet exist, but SQLite will create it for us.
    3. Tell SQLite to open the the database file, this will create the file if it doesn't already exist. We also pass it the nil pointer to the database so that it can initialize it.
    4. Check the status of the sqlite3_open() function to make sure everything worked. */
    
    var database: OpaquePointer? // 1
    
    func openDatabase() {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("famous_people.db") // 2
        
        let status = sqlite3_open(fileURL.path, &database) // 3
        if status != SQLITE_OK { // 4
            print("error opening database")
        }
    }
    
    
    // MARK: Closing Database
    
    func closeDatabase() {
        let status = sqlite3_close(database)
        if status != SQLITE_OK {
            print("error closing database")
        }
    }
    
    
    // MARK: Setup Database with default values
    
    func setupData() {
        let createPeople =
        """
        CREATE TABLE famous_people (
        id INTEGER PRIMARY KEY,
        first_name VARCHAR(50),
        last_name VARCHAR(50),
        birthdate DATE
        );

        INSERT INTO famous_people (first_name, last_name, birthdate)
        VALUES ('Abraham', 'Lincoln', '1809-02-12');
        INSERT INTO famous_people (first_name, last_name, birthdate)
        VALUES ('Mahatma', 'Gandhi', '1869-10-02');
        INSERT INTO famous_people (first_name, last_name, birthdate)
        VALUES ('Paul', 'Rudd', '1969-04-06');
        INSERT INTO famous_people (first_name, last_name, birthdate)
        VALUES ('James', 'Kirk', '2233-03-22');
        INSERT INTO famous_people (first_name, last_name, birthdate)
        VALUES ('S''chn T''gai', 'Spock', '2230-01-06');
        INSERT INTO famous_people (first_name, last_name, birthdate)
        VALUES ('Nathan', 'Hsu', '1989-01-19');
        INSERT INTO famous_people (first_name, last_name, birthdate)
        VALUES ('Barack', 'Obama', '1961-08-04');
        INSERT INTO famous_people (first_name, last_name, birthdate)
        VALUES ('Steve', 'Jobs', '1955-02-24');
        INSERT INTO famous_people (first_name, last_name, birthdate)
        VALUES ('Taylor', 'Swift', '1989-12-13');
        INSERT INTO famous_people (first_name, last_name, birthdate)
        VALUES ('Ed', 'Sheeran', '1991-02-17');
        """
        
        let status = sqlite3_exec(database, createPeople, nil, nil, nil) // 2
        if status != SQLITE_OK { // 3
            let errmsg = String(cString: sqlite3_errmsg(database)!)
            print("error: \(errmsg)")
        }
    }
    
    
    // MARK: Queries
    /*
     1. Create an SQL query for all the famous people.
     2. Prepare the query.
     3. Make sure that the prepare was successful.
     4. Execute the query for the first result. Also, get the number of columns returned by the query. (This query will return 3 for (first_name, last_name, birthdate)
     5. Create a new array to hold all of the people from the database.
     6. Create a while loop to loop through every row from the database. (This is each person)
     7. Create a for loop to loop through each column(first_name, last_name, birthdate), and create a new person dictionary.
     8. Add the person dictionary to the array.
     9. Execute the query for the next result.
     10. Check for any errors.
     11. Close and deallocate the query.
     12. Return the users.
     
     */
    func getAllPeople() -> [[String: String]]? {
        let queryString =
        """
        SELECT first_name, last_name, birthdate
        FROM famous_people
        ORDER BY birthdate
        ;
        """ // 1
        
        var queryStatement: OpaquePointer? = nil // 2
        let prepareStatus = sqlite3_prepare_v2(database, queryString, -1, &queryStatement, nil)
        
        guard prepareStatus == SQLITE_OK else { // 3
            let errmsg = String(cString: sqlite3_errmsg(database)!)
            print("perpare error: \(errmsg)")
            return nil
        }
        
        var stepStatus = sqlite3_step(queryStatement) // 4
        let numberOfColumns = sqlite3_column_count(queryStatement)
        
        var people = [[String: String]]() // 5
        
        while(stepStatus == SQLITE_ROW) { // 6
            var person = [String: String]()
            
            for i in 0..<numberOfColumns { // 7
                let columnName = String(cString: sqlite3_column_name(queryStatement, Int32(i)))
                let columnText = String(cString: sqlite3_column_text(queryStatement, Int32(i)))
                person[columnName] = columnText
            }
            
            people.append(person) // 8
            
            stepStatus = sqlite3_step(queryStatement) // 9
        }
        
        if stepStatus != SQLITE_DONE { // 10
            print("Error stepping")
        }
        
        let finalizeStatus = sqlite3_finalize(queryStatement) // 11
        if finalizeStatus != SQLITE_OK {
            print("Error finalizing")
        }
        
        return people // 12
    }
    
    
    func getAllPeople(withNameLike name: String) -> [[String: String]]? {
        let searchString = name
        
        let queryString =
        """
        SELECT first_name, last_name, birthdate
        FROM famous_people
        WHERE first_name LIKE '%\(searchString)%' OR last_name LIKE '%\(searchString)%'
        ORDER BY birthdate
        ;
        """ // 1
        
        var queryStatement: OpaquePointer? = nil // 2
        let prepareStatus = sqlite3_prepare_v2(database, queryString, -1, &queryStatement, nil)
        
        guard prepareStatus == SQLITE_OK else { // 3
            let errmsg = String(cString: sqlite3_errmsg(database)!)
            print("perpare error: \(errmsg)")
            return nil
        }
        
        var stepStatus = sqlite3_step(queryStatement) // 4
        let numberOfColumns = sqlite3_column_count(queryStatement)
        
        var people = [[String: String]]() // 5
        
        while(stepStatus == SQLITE_ROW) { // 6
            var person = [String: String]()
            
            for i in 0..<numberOfColumns { // 7
                let columnName = String(cString: sqlite3_column_name(queryStatement, Int32(i)))
                let columnText = String(cString: sqlite3_column_text(queryStatement, Int32(i)))
                person[columnName] = columnText
            }
            
            people.append(person) // 8
            
            stepStatus = sqlite3_step(queryStatement) // 9
        }
        
        if stepStatus != SQLITE_DONE { // 10
            print("Error stepping")
        }
        
        let finalizeStatus = sqlite3_finalize(queryStatement) // 11
        if finalizeStatus != SQLITE_OK {
            print("Error finalizing")
        }
        
        return people // 12
    }
    
    
    // Will get called by the system when no longer referenced
    deinit {
        closeDatabase()
    }
    

    
    
    
    
    
}
