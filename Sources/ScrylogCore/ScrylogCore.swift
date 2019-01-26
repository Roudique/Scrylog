import Foundation
import ScryLogFileService
import ScryLogHTMLParser

public final class ScrylogCore {
    private let arguments: [String]
    
    private enum FolderNames: String {
        case versions
        
        var string: String { return rawValue }
    }
    
    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }
    
    public func run() throws {
        print("Hi, this is scrylog")

        guard let versionPaths = getCurrentVersionFolders() else {
            return
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
        guard let folderPath = createPrivateFolderIfNeeded() else {
            print("Could not find scrylog directory. Aborting.")
            return nil
        }
        
        // Initialize the FileService.
        guard let fileService = FileService(startDirectoryPath: folderPath) else {
            print("Failed to create file service at path: \(folderPath). Aborting :( ")
            return nil
        }
        
        guard let folders = fileService.getFolderNames() else {
            print("Could not get folders :( Aborting.")
            return nil
        }
        
        guard let versionsFolder = createVersionsFolderIfNeeded(currentFolders: folders) else {
            print("Could not create version folder :( Aborting.")
            return nil
        }
        
        return fileService.getFolderNames(at: [versionsFolder])
    }
    
    func createPrivateFolderIfNeeded() -> String? {
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

        return privateFolderURL.path
    }
    
    func createVersionsFolderIfNeeded(currentFolders: [String]) -> String? {
        return nil
    }
}
