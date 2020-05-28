//
//  SitesTableViewController.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 27/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

private let cellIdentifier = "SitesTableViewCell"

class SitesTableViewController: UITableViewController {

    var viewModel: SitesViewModel!
    private let disposeBag: DisposeBag = DisposeBag()
    private let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        viewModel.initialize().disposed(by: disposeBag)
        viewModel.sitesRequest.onNext(())
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sitesPreviews.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SitesTableViewCell else{
            fatalError(R.string.localizable.cell_error(cellIdentifier))
        }
        
        let site = viewModel.sitesPreviews[indexPath.row]
        cell.configure(site)
        
        cell.onCellClicked = {
            print("clicked")
        }

        return cell
    }
    
    private func setup() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "sort"), style: .plain, target: self, action: nil)
        
        searchController.searchBar.placeholder = R.string.localizable.search_sites_placeholder()
        searchController.searchBar.keyboardAppearance = .light
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        
        tableView.register(SitesTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.separatorStyle = .none
        
        setObservers()
    }
    
    
    
    private func setObservers() {
        viewModel.fetchFinished.subscribe(onNext: { [weak self] in
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        viewModel.alertOfError.subscribe(onNext: { [weak self] in
            let alert = getAlert(title: R.string.localizable.error_alert_title(), message: R.string.localizable.error_alert_message(), actionTitle: R.string.localizable.alert_ok_action())
            self?.present(alert, animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }

}
