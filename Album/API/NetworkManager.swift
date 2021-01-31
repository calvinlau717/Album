//
//  NetworkManager.swift
//  Album
//
//  Created by Calvin Lau on 31/1/2021.
//  Copyright © 2021 Calvin Lau. All rights reserved.
//

import Foundation
import Moya

class NetworkManager {
    
    // Signleton
    static let shared = NetworkManager()

    lazy var searchSerivceProvider: MoyaProvider<SearchApi> = {
        let loggerConfig = NetworkLoggerPlugin.Configuration(logOptions: .verbose)
        return MoyaProvider<SearchApi>(plugins: [NetworkLoggerPlugin(configuration: loggerConfig)])
    }()
    
}
