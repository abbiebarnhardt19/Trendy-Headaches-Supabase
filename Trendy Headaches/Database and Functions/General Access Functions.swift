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

//
//  Database.swift
//  learning_xcode
//
//  Created by Abigail Barnhardt on 8/24/25.
//
//
//  Database.swift
//  learning_xcode
//
//  Created by Abigail Barnhardt on 8/24/25.
//
//
//  General Access Functions.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/30/25.
//
//import Foundation
//import Supabase
//
//extension Database {
//    
//    // Get a single column value using userID from users table
//    func getSingleVal(userId: Int64, col: String) async throws -> String? {
//        let user: User = try await client
//            .from("users")
//            .select()
//            .eq("user_id", value: String(userId))
//            .single()
//            .execute()
//            .value
//        
//        // Map column names to User properties
//        switch col {
//        case "email":
//            return user.email
//        case "password":
//            return user.password
//        case "security_question":
//            return user.securityQuestion
//        case "security_answer":
//            return user.securityAnswer
//        case "background_color":
//            return user.backgroundColor
//        case "accent_color":
//            return user.accentColor
//        default:
//            return nil
//        }
//    }
//    
//    // Get all values for a user from a table where userID is a foreign key
//    func getListVals(userId: Int64, table: String, col: String, filterCol: String? = nil, filterVal: String? = nil) async throws -> [String] {
//        
//        switch table.lowercased() {
//        case "medications":
//            let medications: [Medication] = try await fetchFilteredList(userId: userId, tableName: "medications", filterCol: filterCol, filterVal: filterVal)
//            return medications.compactMap { medication in
//                switch col {
//                case "medication_name":
//                    return medication.medicationName
//                case "medication_category":
//                    return medication.medicationCategory
//                default:
//                    return nil
//                }
//            }
//            
//        case "symptoms":
//            let symptoms: [Symptom] = try await fetchFilteredList(userId: userId, tableName: "symptoms", filterCol: filterCol, filterVal: filterVal)
//            return symptoms.compactMap { symptom in
//                switch col {
//                case "symptom_name":
//                    return symptom.symptomName
//                default:
//                    return nil
//                }
//            }
//            
//        case "triggers":
//            let triggers: [Trigger] = try await fetchFilteredList(userId: userId, tableName: "triggers", filterCol: filterCol, filterVal: filterVal)
//            return triggers.compactMap { trigger in
//                switch col {
//                case "trigger_name":
//                    return trigger.triggerName
//                default:
//                    return nil
//                }
//            }
//            
//        default:
//            return []
//        }
//    }
//    
//    // Helper function to fetch filtered lists
//    private func fetchFilteredList<T: Codable>(userId: Int64, tableName: String, filterCol: String?, filterVal: String?) async throws -> [T] {
//        let endColumnName = "\(tableName.dropLast())_end"
//        
//        var query = client
//            .from(tableName)
//            .select()
//            .eq("user_id", value: String(userId))
//            .is(endColumnName, value: nil)  // Change to nil instead of "null"
//        
//        if let filterCol = filterCol, let filterVal = filterVal {
//            query = query.eq(filterCol, value: filterVal)
//        }
//        
//        let response: [T] = try await query.execute().value
//        return response
//    }
//}
