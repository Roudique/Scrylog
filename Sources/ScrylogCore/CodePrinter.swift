//
//  CodePrinter.swift
//  ScrylogCore
//
//  Created by Roudique on 3/4/19.
//

import Foundation
import ScryLogFileService
import ScryLogHTMLParser


class CodePrinter {
    static func generateCode(for entity: Entity) -> Data? {
        if entity.title == "cards" {
            return generateCardCode(for: entity)
        }
        
        print("Unsupported entity: \(entity.title)")
        exit(0)
    }
    
    private static func generateCardCode(for entity: Entity) -> Data? {
        var correctTables = [Table]()
        
        for table in entity.tables {
            if table.title.lowercased().contains("fields") {
                correctTables.append(table)
            }
        }
        
        var codingKeys =
        """
        \t// CodingKeys
        \tenum CodingKeys: String, CodingKey {
        """
        var codeString = ""
        codeString.append("// Generated with scrylog.\n")
        codeString.append("import Foundation\n\n\n")
        codeString.append("class Card: Decodable {\n")
        
        for table in correctTables {
            if correctTables.first! != table {
                codeString.append("\n")
            }
            
            codeString.append("\t//MARK: - \(table.title)\n")
            codingKeys.append("\n\t\t// \(table.title)\n")
            
            for row in table.rows {
                guard row[0].lowercased() != "property" else { continue }
                
                var realName = row[0]
                let varType = correctType(from: row[1])
                if varType == "Bool" {
                    realName = "is_".appending(realName)
                }
                let varName = snakeCaseToLowercase(str: realName)
                let isOptional = isNullable(string: row[2])
                let description = row[3]
                
                codeString.append("\n\t/// \(description)\n")
                codeString.append("\tvar \(varName): \(varType)\(isOptional ? "?" : "")\n")
                
                codingKeys.append("\n\t\tcase \(varName)\(varName == realName ? "" : " = \"\(realName)\"")")
                
                if table.rows.last! == row {
                    codeString.append("\n")
                    codingKeys.append("\n")
                }
            }
        }
        codingKeys.append("\t}")
        
        codeString.append("\n" + codingKeys + "\n")
        codeString.append("}")
        
        return codeString.data(using: .utf8)
    }
    
    private static func snakeCaseToLowercase(str: String) -> String {
        return str
            .split(separator: "_")  // split to components
            .map { String($0) }   // convert subsequences to String
            .enumerated()  // get indices
            .map {
                if $0.element == "uri" { return "URI" }
                if $0.element == "uris" { return "URIs" }
                if $0.element == "id" { return "ID" }
                if $0.element == "ids" { return "IDs" }
                
                
                // added lowercasing
                return $0.offset > 0 ? $0.element.capitalized : $0.element.lowercased() }
            .joined() // join to one string
    }
    
    private static func correctType(from string: String) -> String {
        let lowercased = string.lowercased()
        
        switch lowercased {
        case "string":
            return "String"
        case "integer":
            return "Int"
        case "uri":
            return "URL"
        case "boolean":
            return "Bool"
        case "decimal":
            return "Double"
        case "date":
            return "Date"
        default:
            return "<#\(lowercased)#>"
        }
    }
    
    private static func isNullable(string: String) -> Bool {
        if string.lowercased() == "nullable" {
            return true
        }
        
        return false
    }

}
