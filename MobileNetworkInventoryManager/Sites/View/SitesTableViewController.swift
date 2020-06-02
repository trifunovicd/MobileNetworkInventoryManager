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
    private let searchBar: UISearchBar = UISearchBar()
    
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
        return viewModel.filteredSitesPreviews.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SitesTableViewCell else{
            fatalError(R.string.localizable.cell_error(cellIdentifier))
        }
        
        let site = viewModel.filteredSitesPreviews[indexPath.row]
        cell.configure(site)
        
        cell.onCellClicked = {
            print("clicked")
        }

        return cell
    }
    
    private func setup() {
        if #available(iOS 13.0, *) {
            UITextField.appearance(whenContainedInInstancesOf: [type(of: searchBar)]).tintColor = .white
        }
        else {
            UITextField.appearance(whenContainedInInstancesOf: [type(of: searchBar)]).tintColor = .darkGray
        }
        searchBar.keyboardAppearance = .light
        searchBar.placeholder = R.string.localizable.search_sites_placeholder()
        searchBar.scopeBarBackgroundImage = UIImage()
        searchBar.scopeButtonTitles = [R.string.localizable.name(), R.string.localizable.address(), R.string.localizable.tech(), R.string.localizable.mark()]
        searchBar.showsScopeBar = true
        searchBar.showsCancelButton = true
        searchBar.sizeToFit()
        searchBar.delegate = self
        
        showSearchBarButton(shouldShow: true)
        
        tableView.register(SitesTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.separatorStyle = .none
        
        viewModel.setupSortView(frame: view.frame)
        
        setObservers()
    }
    
    @objc private func handleShowSearchBar() {
        viewModel.searchClicked.onNext(())
    }
    
    @objc private func openSortOptions() {
        viewModel.sortClicked.onNext(())
    }
    
    private func setObservers() {
        viewModel.fetchFinished.subscribe(onNext: { [weak self] in
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        viewModel.alertOfError.subscribe(onNext: { [weak self] in
            let alert = getAlert(title: R.string.localizable.error_alert_title(), message: R.string.localizable.error_alert_message(), actionTitle: R.string.localizable.alert_ok_action())
            self?.present(alert, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        viewModel.searchClicked.subscribe(onNext: { [weak self] in
            self?.showSearchBar(shouldShow: true)
            self?.searchBar.becomeFirstResponder()
        }).disposed(by: disposeBag)
        
        viewModel.sortClicked.subscribe(onNext: { [weak self] in
            self?.viewModel.sortView.show()
        }).disposed(by: disposeBag)
    }

    private func showSearchBarButton(shouldShow: Bool) {
        if shouldShow {
            navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(handleShowSearchBar)), animated: true)
            navigationItem.setLeftBarButton(UIBarButtonItem(image: #imageLiteral(resourceName: "sort"), style: .plain, target: self, action: #selector(openSortOptions)), animated: true)
        }
        else {
            navigationItem.setRightBarButton(nil, animated: true)
            navigationItem.setLeftBarButton(nil, animated: true)
        }
    }
    
    private func showSearchBar(shouldShow: Bool) {
        searchBar.alpha = shouldShow ? 0 : 1
        showSearchBarButton(shouldShow: !shouldShow)
        navigationItem.titleView = shouldShow ? searchBar : nil
        navigationController?.navigationBar.sizeToFit()
        UIView.animate(withDuration: 0.4, animations: {
            self.searchBar.alpha = shouldShow ? 1 : 0
        })
    }
}


extension SitesTableViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        showSearchBar(shouldShow: false)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.handleTextChange(searchText: searchText, index: SelectedScope(rawValue: searchBar.selectedScopeButtonIndex)!)
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        guard let searchText = searchBar.text else { return }
        viewModel.handleTextChange(searchText: searchText, index: SelectedScope(rawValue: selectedScope)!)
    }
}
