import Foundation
import ScryLogFileService
import ScryLogHTMLParser

enum ScrylogError: Error {
    case couldNotCreateFileService
}

public final class ScrylogCore {
    private let arguments: [String]
    
    private enum FolderNames: String {
        case versions
        
        var string: String { return rawValue }
    }
    
    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }
}

@available(OSX 10.12, *)
public extension ScrylogCore {
    func run() throws {
        guard let privateFolderURL = createPrivateFolderIfNeeded() else { throw ScrylogError.couldNotCreateFileService
            
        }
        
        guard let fileService = FileService(startDirectoryPath: privateFolderURL.path) else {
            throw ScrylogError.couldNotCreateFileService
        }
        
        print("""
            Hi, this is scrylog. You have \(fileService.versions.count) versions of scryfall.com docs.
            """)
        
        ScryfallAPI.fetchLatestDocuments { tablesDict in
            guard let tablesDict = tablesDict else {
                print("Something went wrong, could not fetch latest documents from scryfall.com :(")
                return
            }
            
            let entities = self.parse(response: tablesDict)
            
            // No local versions: create v0.
            guard let lastVersion = fileService.lastVersion else {
                let newVersion = Version(number: 0, entities: entities)
                fileService.add(version: newVersion)
                exit(0)
            }
            
            let fetchedVersion = Version(number: lastVersion.number + 1, entities: entities)
            
            guard let versionDiff = lastVersion.diff(to: fetchedVersion) else { exit(0) }
            
            // Latest local version is the same: do nothing.
            guard versionDiff.count > 0 else {
                print("Current scryfall.com doc set version is the same as latest local version!")
                exit(0)
            }
           
            // Latest local version is different: print conflicting versions.
            self.printDiff(diffs: versionDiff,
                           oldEntities: lastVersion.entities,
                           newEntities: fetchedVersion.entities)
            
            print("Saving new version with number \(fetchedVersion.number)...")
            
            let writeSuccess = fileService.add(version: fetchedVersion)
            
            if writeSuccess {
                print("Done!")
            } else {
                print("Something went wrong :(")
            }
            
            exit(0)
        }

        RunLoop.main.run()
    }
}

@available(OSX 10.12, *)
private extension ScrylogCore {
    func parse(response: [String : [Table]]) -> [Entity] {
        let entityNames = response.keys
        var entities = [Entity]()
        for entityName in entityNames {
            guard let tables = response[entityName] else { continue }
            entities.append(Entity(title: entityName,
                                   tables: tables))
        }
        
        return entities
    }

    func createPrivateFolderIfNeeded() -> URL? {
        let fileManager         = FileManager.default
        let homeDirURL          = fileManager.homeDirectoryForCurrentUser
        let privateFolderURL    = homeDirURL.appendingPathComponent(".scrylog", isDirectory: true)
        
        // Check if private .scrylog folder exists and create if needed.
        if !fileManager.fileExists(atPath: privateFolderURL.path) {
            print("No scrylog folder exists just yet, creating one...")
            
            do {
                try fileManager.createDirectory(at: privateFolderURL,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
            } catch {
                print("Failed to create directory, error: \(error)")
                return nil
            }
        }
        
        return privateFolderURL
    }
}

private extension ScrylogCore {
    func printDiff(diffs: [(entityName: String, diffs: [TableDiff])],
                   oldEntities: Set<Entity>,
                   newEntities: Set<Entity>) {
        print("-------------------\nDiffs:")
        for entityDiff in diffs {
            let entityName = entityDiff.entityName
            print("--- \(entityName)")
            
            for tableDiff in entityDiff.diffs {
                let tableTitle = tableDiff.tableName

                switch tableDiff.type {
                case .insertion:
                    print("\tNew table:\(tableDiff.tableName)")
                case .removal:
                    print("\tRemoved table:\(tableDiff.tableName)")
                case .update(inserts: let inserts, removals: let removals):
                    guard let oldEntity = oldEntities.first(where: { $0.title == entityName }) else {
                        continue
                    }
                    guard let newEntity = newEntities.first(where: { $0.title == entityName }) else {
                        continue
                    }
                    
                    guard let oldTable = oldEntity.tables.first(where: { $0.title ==  tableTitle}) else {
                        continue
                    }
                    guard let newTable = newEntity.tables.first(where: { $0.title ==  tableTitle}) else {
                        continue
                    }

                    printTableDiff(inserts: inserts, removals: removals, oldTable: oldTable, newTable: newTable)
                }
            }
        }
    }
    
    private func printTableDiff(inserts: IndexSet, removals: IndexSet, oldTable: Table, newTable: Table) {
        let totalDiffs = inserts.union(removals)
        let sortedTotalDiffs = Array(totalDiffs).sorted()
        
        print("-- \(newTable.title)")

        for index in sortedTotalDiffs {
            print("Line \(index):")
            if removals.contains(index) {
                print("\t-\(oldTable.rows[index])")
            }
            if inserts.contains(index) {
                print("\t+\(newTable.rows[index])")
            }
            print("")
        }
    }
}

private extension FileService {
    var lastVersion: Version? {
        guard versions.count > 0 else { return nil }
        if versions.count == 1 { return versions.first! }
        
        var versionNumbers = [Int]()
        
        for version in versions {
            versionNumbers.append(version.number)
        }
        
        let maxVersionNumber = versionNumbers.sorted().last!
        let version = versions.first(where: { $0.number == maxVersionNumber })
        
        return version
    }
}
