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

        checkForCurrentData()
    }
}

// MARK: - Private

private extension ScrylogCore {
    func checkForCurrentData() {
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
                return
            }
        }
        
        // Initialize the FileService.
        let scrylogFolderPath = homeDirURL.appendingPathComponent(".scrylog").path
        guard let fileService = FileService(startDirectoryPath: scrylogFolderPath) else {
            print("Failed to create file service at path: \(scrylogFolderPath). Aborting :( ")
            return
        }
        
        guard let folders = fileService.getFolderNames() else {
            print("Could not get folders :( Aborting.")
            return
        }
        
        if !folders.contains(FolderNames.versions.rawValue) {
            
        }
        
    }

}
