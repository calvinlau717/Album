//
//  SearchAlbumViewModel.swift
//  Album
//
//  Created by Calvin Lau on 31/1/2021.
//  Copyright © 2021 Calvin Lau. All rights reserved.
//

import Foundation
import RxSwift


class SearchAlbumViewModel {
    
    struct Input {
        let didSearch: AnyObserver<String>
        let fetchBookmakrs: AnyObserver<Set<Int>>
    }
    
    struct Output {
        let searchResults: Observable<(Album.SearchResults, String)> // (search result, search input text)
        let bookmarks: Observable<(Album.SearchResults)>
        let isLoading: Observable<Bool>
    }
    
    private let didSearchSubject = PublishSubject<String>()
    private let fetchBookmakrs = PublishSubject<Set<Int>>()
    
    let input: Input
    let output: Output
    
    init(searchService: SearchServiceProtocol = SearchService.shared) {
        input = Input(didSearch: didSearchSubject.asObserver(), fetchBookmakrs: fetchBookmakrs.asObserver())
        
        let isLoading = BehaviorSubject<Bool>(value: false)
        
        let searchResults = didSearchSubject.debounce(.milliseconds(100), scheduler: MainScheduler.instance)
            .flatMapLatest { (inputSearchText) -> Observable<Album.SearchResults> in
                let entity = Album.Search.Entity.album.rawValue
                return SearchAlbumViewModel.performSearch(searchService: searchService, searchContent: Album.Search(term: inputSearchText, entity: entity))
//                    .do(onNext:{ _ in
//                        isLoading.onNext(false)
//                    })
        }
        
        let bookmarks = fetchBookmakrs.startWith(Album.Search.getCollectionId() ?? Set<Int>()).distinctUntilChanged()
            .flatMapLatest { collectionIds -> Observable<Album.SearchResults> in
                return SearchAlbumViewModel.performSearch(searchService: searchService, searchId: collectionIds)
        }.debug("bookmarks")
        
        output = Output(searchResults: Observable.combineLatest(searchResults, didSearchSubject.asObservable()),
                        bookmarks: bookmarks.asObservable(),
                        isLoading: isLoading.asObservable())
    }
    
}

// MARK: Search request
extension SearchAlbumViewModel {
    private static func performSearch(searchService: SearchServiceProtocol, searchContent: Album.Search) -> Observable<Album.SearchResults> {
        return searchService.search(content: searchContent)
            .asObservable()
            .catchErrorJustReturn(Album.SearchResults(resultCount: 0, results: []))
    }
    
    private static func performSearch(searchService: SearchServiceProtocol, searchId: Set<Int>) -> Observable<Album.SearchResults> {
        return searchService.search(collectionIds: searchId)
            .asObservable()
            .catchErrorJustReturn(Album.SearchResults(resultCount: 0, results: []))
    }
}
