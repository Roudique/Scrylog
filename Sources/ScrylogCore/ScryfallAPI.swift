//
//  ScryfallAPI.swift
//  scrylog
//
//  Created by Roudique on 1/25/19.
//

import Foundation
import ScryLogHTMLParser

public class ScryfallAPI {
    private static let links = ["https://scryfall.com/docs/api/errors",
                                "https://scryfall.com/docs/api/lists",
                                "https://scryfall.com/docs/api/sets",
                                "https://scryfall.com/docs/api/cards",
                                "https://scryfall.com/docs/api/rulings",
                                "https://scryfall.com/docs/api/card-symbols",
                                "https://scryfall.com/docs/api/catalogs"
    ]

}

public extension ScryfallAPI {
    static func fetchLatestDocuments(completion: @escaping ([String: [Table]]?) -> Void) {
        let tablesDict = [String: [Table]]()

        fetchDocument(index: 0, tablesDict: tablesDict, completion: completion)
    }
}

private extension ScryfallAPI {
    static func fetchDocument(index: Int,
                              tablesDict: [String: [Table]],
                              completion: @escaping ([String: [Table]]?) -> Void) {
        let url = URL(string: self.links[index])!
        let dataTask = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else {
                completion(nil)
                return
            }
            
            let tables = ScryLogHTMLParser.parse(data: data)
            let title = url.lastPathComponent
            
            var newTablesDict = tablesDict
            newTablesDict[title] = tables
            let newIndex = index + 1
            
            if newIndex == self.links.count {
                completion(newTablesDict)
            } else {
                fetchDocument(index: newIndex, tablesDict: newTablesDict, completion: completion)
            }
        }
        dataTask.resume()
    }

}
