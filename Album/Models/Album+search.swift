//
//  Album+search.swift
//  Album
//
//  Created by Calvin Lau on 28/1/2021.
//  Copyright © 2021 Calvin Lau. All rights reserved.
//

import Foundation

extension Album {
    struct Search {
        var term: String
        var entity: String
        
        enum Entity: String {
            // https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/iTuneSearchAPI/Searching.html#//apple_ref/doc/uid/TP40017632-CH5-SW2
            case album
        }
    }
}

extension Album.Search {
    static let KEY_COLLECTION_ID_SET = "KEY_COLLECTION_ID_SET"
    
    static func addCollection(_ id: Int) {
        var currentCollection: Set<Int> = getCollectionId() ?? Set<Int>()
        currentCollection.insert(id)
        
        let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: currentCollection, requiringSecureCoding: false)
        
        UserDefaults.standard.set(encodedData, forKey: KEY_COLLECTION_ID_SET)
    }
    
    static func removeCollection(_ id: Int) {
        var currentCollection = getCollectionId() ?? Set<Int>()
        currentCollection.remove(id)
        
        let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: currentCollection, requiringSecureCoding: false)
        
        UserDefaults.standard.set(encodedData, forKey: KEY_COLLECTION_ID_SET)
    }
    
    static func getCollectionId() -> Set<Int>? {
        guard let decoded = UserDefaults.standard.object(forKey: KEY_COLLECTION_ID_SET) as? Data else {
            return nil
        }
        let decodedSet = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decoded)
        return decodedSet as? Set<Int>
    }
}
