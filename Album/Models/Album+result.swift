//
//  Album+result.swift
//  Album
//
//  Created by Calvin Lau on 31/1/2021.
//  Copyright © 2021 Calvin Lau. All rights reserved.
//

import UIKit

extension Album {
    struct SearchResults: Codable {
        var resultCount: Int
        var results: [Result]
        
        struct Result: Codable {
            var collectionId: Int
            var collectionName: String
            var collectionViewUrl: URL?
            var artistName: String
            var artworkUrl60: URL?
            var artworkUrl100: URL?
            var primaryGenreName: String
        }
    }
}


extension Album.SearchResults.Result: CustomStringConvertible {
    var description: String {
        return "collectionId:\(collectionId)|artworkUrl60:\(artworkUrl60)|artistName:\(artistName)"
    }
    
    var isBookmarked: Bool {
        // TODO: check collectionId
        return false
    }
    
    var bookmarkImage: UIImage? {
        return isBookmarked ? UIImage(named: "ic_bookmark") : UIImage(named: "ic_unbookmark")
    }
}

//"resultCount":50,
//"results":[
//
//    {
//        "wrapperType":"collection",
//        "collectionType":"Album",
//        "artistId":909253,
//        "collectionId":1440857781,
//        "amgArtistId":468749,
//        "artistName":"Jack Johnson",
//        "collectionName":"In Between Dreams (Bonus Track Version)",
//        "collectionCensoredName":"In Between Dreams (Bonus Track Version)",
//        "artistViewUrl":"https://music.apple.com/us/artist/jack-johnson/909253?uo=4",
//        "collectionViewUrl":"https://music.apple.com/us/album/in-between-dreams-bonus-track-version/1440857781?uo=4",
//        "artworkUrl60":"https://is2-ssl.mzstatic.com/image/thumb/Music118/v4/24/46/97/24469731-f56f-29f6-67bd-53438f59ebcb/source/60x60bb.jpg",
//        "artworkUrl100":"https://is2-ssl.mzstatic.com/image/thumb/Music118/v4/24/46/97/24469731-f56f-29f6-67bd-53438f59ebcb/source/100x100bb.jpg",
//        "collectionPrice":11.99,
//        "collectionExplicitness":"notExplicit",
//        "trackCount":16,
//        "copyright":"℗ 2013 Jack Johnson",
//        "country":"USA",
//        "currency":"USD",
//        "releaseDate":"2005-03-01T08:00:00Z",
//        "primaryGenreName":"Rock"
//    },
