//
//  MainViewController.swift
//  Album
//
//  Created by Calvin Lau on 28/1/2021.
//  Copyright © 2021 Calvin Lau. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import RxOptional

class MainViewController: UIViewController {
    
    // MARK: View
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: UITableView.Style.grouped)
        tv.isHidden = true
        return tv
    }()
    
    private let placeholderView: SearchPlaceholderView = {
        let v = SearchPlaceholderView()
        v.isHidden = true
        return v
    }()
    
    private let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        return searchController
    }()
    
    // MARK: View Model
    private lazy var viewModel: SearchAlbumViewModel = {
        return SearchAlbumViewModel()
    }()
    
    // MARK: Data source
    private var result: Album.SearchResults?
    private var bookmarks: Album.SearchResults?
    
    private var isSearching: Bool {
        guard let text = searchController.searchBar.text else {
            return false
        }
        return !text.isEmpty
    }
    
    private var displayMode: MainViewController.Display = .bookmark
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
        
    private func setup() {
        viewSetup()
        tableViewSetup()
        searchControllerSetup()
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.output.searchResults
            .subscribe(onNext: { [weak self] data in
                let (searchResult, _) = data
                self?.result = searchResult
                self?.reloadData()
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.output.bookmarks
            .subscribe(onNext: { [weak self] bookmarks in
                self?.bookmarks = bookmarks
                self?.reloadData()
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    private func viewSetup() {
        title = "Album"
        view.backgroundColor = .darkBackground
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(placeholderView)
        placeholderView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
        }
    }
    
    private func tableViewSetup() {
        tableView.backgroundColor = .darkBackground
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellType: AlbumTableViewCell.self)
        tableView.keyboardDismissMode = .onDrag
    }
    
    // Reference: https://www.raywenderlich.com/4363809-uisearchcontroller-tutorial-getting-started
    private func searchControllerSetup() {
        let searchBar = searchController.searchBar
//        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchBar.placeholder = "Search Album..."
        searchBar.searchTextField.leftView?.tintColor = .white
        
        self.navigationItem.searchController = searchController
        definesPresentationContext = true
        
        searchController.searchBar.rx.text
            .filterNil()
            .distinctUntilChanged()
            .bind(to: viewModel.input.didSearch)
            .disposed(by: rx.disposeBag)
         
        // Switch between Placeholder (bookmarked album) <-> search result
        let isSearching = searchController.searchBar.rx.text.map{ !($0?.isEmpty ?? true) }.share()
        isSearching.asObservable()
            .subscribe(onNext: { [weak self] isSearching in
                self?.reloadData()
            })
            .disposed(by: rx.disposeBag)
        
        
        // Fetch bookmarks when not searching
        isSearching
            .map{ _ in Album.Search.getCollectionId() }
            .filterNil()
            .bind(to: viewModel.input.fetchBookmakrs)
            .disposed(by: rx.disposeBag)
    }

    private func fetchMode() {
        let showBookmarksResult = !isSearching && !(bookmarks?.results.isEmpty ?? true)
        if isSearching {
            self.displayMode = .searchResult
            return
        }
        
        if showBookmarksResult {
            self.displayMode = .bookmark
            return
        }
        
        self.displayMode = .placeholder
    }
    
    // Show placeholderView, search result or bookmarks
    private func reloadData() {
        fetchMode()
        switch displayMode {
        case .searchResult, .bookmark:
            tableView.isHidden = false
            placeholderView.isHidden = true
        case .placeholder:
            tableView.isHidden = true
            placeholderView.isHidden = false
        }
        tableView.reloadData()
    }
}

extension MainViewController: UITableViewDelegate {
    
}

// MARK: TableView data source
extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let bookmarks = self.bookmarks?.results.count ?? 0
        let searchResult = self.result?.results.count ?? 0
        return isSearching ? searchResult : bookmarks
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: AlbumTableViewCell.self, for: indexPath)
        let result = isSearching ? self.result?.results[indexPath.row] : self.bookmarks?.results[indexPath.row]
        cell.config(result)
        
        cell.bookmarkBtn.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                guard let kResult = result else {
                    return
                }
                if kResult.isBookmarked {
                    // unbookmarked, remove the collectionId and fetch bookmarks
                    Album.Search.removeCollection(kResult.collectionId)
                    self?.viewModel.input.fetchBookmakrs.onNext(Album.Search.getCollectionId() ?? Set<Int>())
                    return
                } else {
                    Album.Search.addCollection(kResult.collectionId)
                }
                self?.tableView.reloadRows(at: [indexPath], with: .none)
            })
            .disposed(by: cell.disposeBag)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let lbl = UILabel()
        lbl.textColor = .descText
        lbl.font = UIFont.systemFont(ofSize: 30, weight: .light)
        
        switch displayMode {
        case .searchResult:
            lbl.text = "Search results"
        case .bookmark:
            lbl.text = "Bookmarks"
        case .placeholder:
            return nil
        }
        
        let container = UIView()
        container.backgroundColor = .darkBackground
        container.addSubview(lbl)
        lbl.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 0))
        }
        
        return container
    }
}

// MARK: Display mode
extension MainViewController {
    enum Display {
        case searchResult
        case bookmark
        case placeholder
    }
}

