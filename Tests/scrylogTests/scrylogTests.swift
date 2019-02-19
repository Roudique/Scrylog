import XCTest
import class Foundation.Bundle
import ScryLogHTMLParser
import ScryLogFileService

final class scrylogTests: XCTestCase {
    func makeTable(title: String = "Test") -> Table {
        return Table(title: title, rows: [["00", "01"],
                                          ["10", "11"]])
    }
    
    func testTableDiff() {
        let table1 = makeTable(title: "tableTitle")
        let table2 = Table(title: "tableTitle", rows: [["00", "x"],
                                                    ["10", "11"],
                                                    ["20", "21"],
                                                    ["00", "01"]])

        let diff = table1.diff(to: table2)!
        switch diff.type {
        case .update(inserts: let inserts, removals: let removals):
            XCTAssert(inserts.count == 3 && removals.count == 1)
        default:
            XCTAssert(false)
        }
    }
    
    func testEntityDiffInsertedAndUpdatedTables() {
        let table1 = makeTable(title: "01")
        let table2 = makeTable(title: "02")
        let table3 = makeTable(title: "03")
        let table2modified = Table(title: "02", rows: [["00", "x"],
                                                       ["10", "11"]])
        
        let entity1 = Entity(title: "test", tables: [table1, table2])
        let entity2 = Entity(title: "test", tables: [table1, table2modified, table3])
        
        let diffs = entity1.diff(to: entity2)!
        
        var insertedTablesCount = 0
        var updatedTablesCount  = 0
        var removedTablesCount  = 0
        
        for diff in diffs {
            switch diff.type {
            case .insertion:
                insertedTablesCount += 1
            case .update(inserts: _, removals: _):
                updatedTablesCount += 1
            case .removal:
                removedTablesCount += 1
            }
        }
        
        XCTAssert(insertedTablesCount == 1)
        XCTAssert(updatedTablesCount == 1)
        XCTAssert(removedTablesCount == 0)
    }
    
    func testEntityDiffIsNilIfNamesDontMatch() {
        let entity1 = Entity(title: "entity1", tables: [Table]())
        let entity2 = Entity(title: "entity2", tables: [Table]())
        
        XCTAssert(entity1.diff(to: entity2) == nil)
    }
    
    func testVersionsAreSame() {
        let table1 = makeTable(title: "01")
        let table2 = makeTable(title: "02")
        let table3 = makeTable(title: "03")
        
        let entity1 = Entity(title: "01", tables: [table1, table2])
        let entity2 = Entity(title: "02", tables: [table3])
        
        let version1 = Version(number: 0, entities: [entity1, entity2])
        let version2 = Version(number: 1, entities: [entity1, entity2])
        
        let diff = version1.diff(to: version2)!
        XCTAssert(diff.count == 0)
    }
    
    func testVersionsAreDifferent() {
        let table1 = makeTable(title: "01")
        let table2 = makeTable(title: "02")
        let table3 = makeTable(title: "03")
        let table1modified = Table(title: table1.title, rows: [["00", "x"],
                                                               ["10", "11"]])
        let table3modified = Table(title: table3.title, rows: [["10", "11"],
                                                               ["00", "01"]])

        let entity1 = Entity(title: "01", tables: [table1, table2])
        let entity2 = Entity(title: "02", tables: [table3])
        let entity1modified = Entity(title: entity1.title, tables: [table1modified, table2])
        let entity2modified = Entity(title: entity2.title, tables: [table3modified])
        
        let version1 = Version(number: 0, entities: [entity1, entity2])
        let version2 = Version(number: 1, entities: [entity1modified, entity2modified])

        let diff = version1.diff(to: version2)!
        XCTAssert(diff.count == 2)
    }

    static var allTests = [
        ("testTableDiff", testTableDiff,
         "testEntityDiffInsertedAndUpdatedTables", testEntityDiffInsertedAndUpdatedTables,
         "testEntityDiffIsNilIfNamesDontMatch", testEntityDiffIsNilIfNamesDontMatch),
    ]
}
