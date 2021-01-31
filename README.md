# Album 
- Show list of albums fetched from itunes 
- Bookmark

## Demo
- ![Alt Text](https://media.giphy.com/media/zOSJDvjx6f8c8279zP/giphy.gif)

## Implementation
- Search 
    - https://itunes.apple.com/search?entity=album&term={search_input}

- Bookmarks (Search by collectinIds)
    - https://itunes.apple.com/lookup?entity=album&id={collectionIds}

- Network 
    - moya+Rxswift 
    - NetworkManager, SearchApi, SearchService

- ViewModel + RxSwift
    - SearchAlbumViewModel
        ``` swift 
        let searchResults = didSearchSubject.debounce(.milliseconds(100), scheduler: MainScheduler.instance)
            .flatMapLatest { (inputSearchText) -> Observable<Album.SearchResults> in
                let entity = Album.Search.Entity.album.rawValue
                return SearchAlbumViewModel.performSearch(searchService: searchService, searchContent: Album.Search(term: inputSearchText, entity: entity))
        }
        ```
        ``` swift
        private static func performSearch(searchService: SearchServiceProtocol, searchId: Set<Int>) -> Observable<Album.SearchResults> {
        return searchService.search(collectionIds: searchId)
            .asObservable()
            .catchErrorJustReturn(Album.SearchResults(resultCount: 0, results: []))
        }
        ```

## Reference

- iTunes API
    - https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/iTuneSearchAPI/SearchExamples.html#//apple_ref/doc/uid/TP40017632-CH6-SW1

- SearchController
    - https://www.raywenderlich.com/4363809-uisearchcontroller-tutorial-getting-started

- Color reference
    - https://uxdesign.cc/dark-mode-ui-design-the-definitive-guide-part-1-color-53dcfaea5129