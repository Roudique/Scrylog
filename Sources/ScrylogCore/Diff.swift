//
//  VersionDiff.swift
//  ScrylogCore
//
//  Created by Roudique on 2/3/19.
//

import Foundation
import FlexibleDiff
import ScryLogFileService
import ScryLogHTMLParser

struct TableDiff {
    enum DiffType {
        case update(inserts: IndexSet, removals: IndexSet)
        case insertion, removal
    }
    
    let tableName: String
    let type: DiffType
}

extension Table {
    func diff(to other: Table) -> TableDiff? {
        if self.title != other.title { return nil }
        
        let changeset = Changeset(previous: self.rows, current: other.rows)
        
        let removals = changeset.removals.union(IndexSet(changeset.moves.map { $0.source }))
        let inserts = changeset.inserts.union(IndexSet(changeset.moves.map { $0.destination }))
        
        print("table1:\n\t\(self.rows)\n\ntable2:\n\t\(other.rows)\n")
        
        print("""
            - deleted \(removals.count) item(s) at [\(removals.map(String.init).joined(separator: ", "))]"
            - inserted \(inserts.count) item(s) at [\(inserts.map(String.init).joined(separator: ", "))]"
            """)
        
        if inserts.count == 0 && removals.count == 0 { return nil }
        
        return TableDiff(tableName: self.title, type: .update(inserts: inserts, removals: removals))
    }
}

extension Entity {
    func diff(to other: Entity) -> [TableDiff]? {
        if self.title != other.title { return nil }
        
        var diffs = [TableDiff]()
        
        for table in self.tables {
            if let otherTable = other.tables.first(where: { $0.title == table.title }) {
                // If there is no diff it means tables are identical thus continue.
                guard let diff = table.diff(to: otherTable) else { continue }
                
                diffs.append(diff)
            } else {
                // If table doesn't exist in other entity it means it is removed.
                diffs.append(TableDiff(tableName: table.title, type: .removal))
            }
        }
        
        // Mark all tables that don't exist in current entity as insertions.
        for otherTable in other.tables {
            guard self.tables.first(where: { $0.title == otherTable.title }) == nil else { continue }
            diffs.append(TableDiff(tableName: otherTable.title, type: .insertion))
        }
        
        return diffs
    }
}