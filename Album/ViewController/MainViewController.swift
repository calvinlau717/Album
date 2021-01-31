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

class MainViewController: UIViewController, Searchable {
    
    var isSearching: BehaviorSubject<Bool> = BehaviorSubject<Bool>(value: false)
    
    // MARK: View
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        return tv
    }()
    
    private let placeholderView: SearchPlaceholderView = {
        return SearchPlaceholderView()
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
                self?.tableView.reloadData()
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
         
        let isSearching = searchController.searchBar.rx.text.map{ !($0?.isEmpty ?? true) }
        isSearching.map{ !$0 }
            .bind(to: tableView.rx.isHidden)
            .disposed(by: rx.disposeBag)
        
        isSearching
            .bind(to: placeholderView.rx.isHidden)
            .disposed(by: rx.disposeBag)    }
}


extension MainViewController: UITableViewDelegate {
    
}

// MARK: TableView data source
extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result?.results.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: AlbumTableViewCell.self, for: indexPath)
        let result = self.result?.results[indexPath.row]
        cell.config(result)
        
        cell.bookmarkBtn.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                guard let kResult = result else {
                    return
                }
                if kResult.isBookmarked {
                    Album.Search.removeCollection(kResult.collectionId)
                } else {
                    Album.Search.addCollection(kResult.collectionId)
                }
                self?.tableView.reloadRows(at: [indexPath], with: .none)
            })
            .disposed(by: cell.disposeBag)
        
        return cell
    }
}

protocol Searchable: UIViewController {
    var isSearching: BehaviorSubject<Bool> { get set }
}

extension Reactive where Base: UISearchController {
    public var active: ControlProperty<Bool> {
        
        let soruce: Observable<Bool> = Observable.deferred { [weak searchController = self.base as UISearchController] () -> Observable<Bool> in
            let isActive = searchController?.isActive ?? false
            return Observable<Bool>.just(isActive).startWith(false)
        }
        
        let bindingObserver = Binder(self.base) { (searchController, isActive: Bool) in
//            searchController.isActive = isActive
        }
        
        return ControlProperty(values: soruce, valueSink: bindingObserver)
    }
}

// Reference
/// Reactive wrapper for `text` property.
//public var value: ControlProperty<String?> {
//    let source: Observable<String?> = Observable.deferred { [weak searchBar = self.base as UISearchBar] () -> Observable<String?> in
//        let text = searchBar?.text
//
//        let textDidChange = (searchBar?.rx.delegate.methodInvoked(#selector(UISearchBarDelegate.searchBar(_:textDidChange:))) ?? Observable.empty())
//        let didEndEditing = (searchBar?.rx.delegate.methodInvoked(#selector(UISearchBarDelegate.searchBarTextDidEndEditing(_:))) ?? Observable.empty())
//
//        return Observable.merge(textDidChange, didEndEditing)
//                .map { _ in searchBar?.text ?? "" }
//                .startWith(text)
//    }
//
//    let bindingObserver = Binder(self.base) { (searchBar, text: String?) in
//        searchBar.text = text
//    }
//
//    return ControlProperty(values: source, valueSink: bindingObserver)
//}
