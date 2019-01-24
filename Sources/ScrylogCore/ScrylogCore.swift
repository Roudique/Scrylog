import Foundation

public final class ScrylogCore {
    private let arguments: [String]
    
    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }
    
    public func run() throws {
        print("Hi, this is ScrylogCore")
    }
}
