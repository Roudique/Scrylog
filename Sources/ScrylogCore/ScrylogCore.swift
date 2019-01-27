import Foundation
import ScryLogFileService
import ScryLogHTMLParser

struct ScrylogError: Error {}

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

public extension ScrylogCore {
    func run() throws {
        print("Hi, this is scrylog")
        
        guard let versions = getCurrentVersionFolders() else {
            throw ScrylogError()
        }
        
        
        
        
        
        // Compare fetched version to local versions. If:
        //  a) No local versions: create v1.
        //  b) Latest local version is different: return conflicting versions.
        //  c) Latest local version is the same: do nothing.
    }
}

// MARK: - Private

private extension ScrylogCore {
    func getCurrentVersionFolders() -> [String]? {
        guard let privateFolder = createPrivateFolderIfNeeded() else {
            print("Could not find scrylog directory. Aborting.")
            return nil
        }
        
        // Initialize the FileService.
        guard let fileService = FileService(startDirectoryPath: privateFolder.path) else {
            print("Failed to create file service at path: \(privateFolder.path). Aborting :( ")
            return nil
        }
        
        guard let versionsFolderURL = createVersionsFolderIfNeeded(containigFolderURL: privateFolder) else {
            print("Could not create version folder :( Aborting.")
            return nil
        }
        
        return fileService.getFolderNames(at: [versionsFolderURL.lastPathComponent])
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
    
    func createVersionsFolderIfNeeded(containigFolderURL: URL) -> URL? {
        let versionsFolderURL = containigFolderURL.appendingPathComponent(FolderNames.versions.string)
        
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: versionsFolderURL.path) {
            do {
                try fileManager.createDirectory(atPath: versionsFolderURL.path,
                                            withIntermediateDirectories: false,
                                            attributes: nil)
            } catch {
                return nil
            }
        }
        
        return versionsFolderURL
    }
}
