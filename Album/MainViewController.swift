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
        let tv = UITableView(frame: .zero, style: .plain)
        return tv
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
    }
    
    private func tableViewSetup() {
        tableView.backgroundColor = .darkBackground
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellType: AlbumTableViewCell.self)
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
    }
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
        cell.config(result?.results[indexPath.row])
        return cell
    }
}


//extension MainViewController: UISearchResultsUpdating {
//    func updateSearchResults(for searchController: UISearchController) {
//        guard let t = searchController.searchBar.text else {
//            return
//        }
//        print("[t]\(t)")
//    }
//}
