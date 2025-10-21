//
//  General Access Functions.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/30/25.
//

import SQLite

extension Database {
    
    // get a single column value using userID
    func getSingleVal(userId: Int64, col: String) -> String? {
        do {
            //set variables
            let idColumn = SQLite.Expression<Int64>("user_id")
            let targetColumn = SQLite.Expression<String>(col)
            
            //grab the row and column
            if let row = try pluck(users.filter(idColumn == userId)) {
                return row[targetColumn]
            }
        } catch {
            print("SQLite error in getSingleColumnValue: \(error)")
        }
        return nil
    }
    
    //get all the values for a user from a table where userID is a foreign key
    func getListVals(userId: Int64, table: String, col: String,  filterCol: String? = nil, filterVal: String? = nil) -> [String] {
        do {
            //set variables
            let idColumn = SQLite.Expression<Int64>("user_id")
            let targetColumn = SQLite.Expression<String>(col)
            let SQLTable = Table(table)
            
            var query = SQLTable.filter(idColumn == userId)
            
            //ensure values are current, use the table name to create the end column name
            let endColumnName = "\(table.lowercased().dropLast())_end"
            let endColumn = SQLite.Expression<String?>(endColumnName)
            
            //get all the values for the user where there is no end
            query = query.filter(endColumn == nil)
            if let filterCol, let filterVal {
                let extraColumn = SQLite.Expression<String>(filterCol)
                query = query.filter(extraColumn == filterVal)
            }
            
            //actually run the queries to get the results
            let results = try prepare(query).map { row in
                row[targetColumn]
            }
            return results
            
        } catch {
            print("SQLite error in getForeignKeyColumnValues: \(error)")
            return []
        }
    }
}
