//
//  SearchApi.swift
//  Album
//
//  Created by Calvin Lau on 28/1/2021.
//  Copyright © 2021 Calvin Lau. All rights reserved.
//

import Foundation
import Moya

enum SearchApi {
    case search(content: Album.Search)
    case searchIds(collectionIds: Set<Int>)
}

extension SearchApi: TargetType {
    var baseURL: URL {
        guard let url = URL(string: "https://itunes.apple.com/") else {
            fatalError("baseURL could not be configured.")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .search:
            return "search"
        case .searchIds:
            return "lookup"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .search(let content):
            let params = [
                "term" : content.term,
                "entity": content.entity
            ]
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .searchIds(let collectionIds):
            let kCollectionIds = Array(collectionIds).map{"\($0)"}
            let params = [
                "id" : kCollectionIds.joined(separator: ","),
                "entity": Album.Search.Entity.album.rawValue
            ]
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/x-www-form-urlencoded"]
    }
    
    
}

