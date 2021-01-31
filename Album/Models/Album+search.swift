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
