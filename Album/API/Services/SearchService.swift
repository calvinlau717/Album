//
//  SearchService.swift
//  Album
//
//  Created by Calvin Lau on 28/1/2021.
//  Copyright © 2021 Calvin Lau. All rights reserved.
//

import Foundation
import RxSwift
import Moya

protocol SearchServiceProtocol {
    func search(content: Album.Search) -> Single<Album.SearchResults>
}

class SearchService: SearchServiceProtocol {
    
    static let shared = SearchService()
    
    func search(content: Album.Search) -> Single<Album.SearchResults> {
        return NetworkManager.shared.searchSerivceProvider.rx.request(.search(content: content))
            .map(Album.SearchResults.self)
    }
}
