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
    
    private let myRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .gray
        refreshControl.attributedTitle = NSAttributedString(string: R.string.localizable.refresh_control_title(), attributes: [NSAttributedString.Key.foregroundColor:UIColor.gray])
        return refreshControl
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.keyboardAppearance = .light
        searchBar.placeholder = R.string.localizable.search_sites_placeholder()
        searchBar.scopeBarBackgroundImage = UIImage()
        searchBar.scopeButtonTitles = [R.string.localizable.name(), R.string.localizable.address(), R.string.localizable.tech(), R.string.localizable.mark()]
        searchBar.showsScopeBar = true
        searchBar.showsCancelButton = true
        searchBar.sizeToFit()
        return searchBar
    }()
    
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
        
        cell.onCellClicked = { [weak self] in
            self?.viewModel.showSiteDetails(sitePreview: site)
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
        
        searchBar.delegate = self
        
        tableView.register(SitesTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.separatorStyle = .none
        
        tableView.refreshControl = myRefreshControl
        
        setObservers()
        viewModel.setupSortView(frame: view.frame)
        viewModel.showNavigationButtons.onNext(true)
    }
    
    @objc private func handleShowSearchBar() {
        viewModel.filterAction.onNext(true)
    }
    
    @objc private func openSortOptions() {
        viewModel.sortView.show()
    }
    
    private func setObservers() {
        myRefreshControl.rx.controlEvent(.valueChanged).asObservable().subscribe(onNext: { [weak self] in
            self?.viewModel.sitesRequest.onNext(())
        }).disposed(by: disposeBag)
        
        viewModel.endRefreshing.subscribe(onNext: { [weak self] in
            self?.myRefreshControl.endRefreshing()
        }).disposed(by: disposeBag)
        
        viewModel.fetchFinished.subscribe(onNext: { [weak self] in
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        viewModel.alertOfError.subscribe(onNext: { [weak self] in
            let alert = getAlert(title: R.string.localizable.error_alert_title(), message: R.string.localizable.error_alert_message(), actionTitle: R.string.localizable.alert_ok_action())
            self?.present(alert, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        viewModel.filterAction.subscribe(onNext: { [weak self] shouldShow in
            self?.showSearchBar(shouldShow: shouldShow)
        }).disposed(by: disposeBag)
        
        viewModel.showNavigationButtons.subscribe(onNext: { [weak self] shouldShow in
            self?.showNavigationButtons(shouldShow: shouldShow)
        }).disposed(by: disposeBag)
    }

    private func showNavigationButtons(shouldShow: Bool) {
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
        if shouldShow {
            searchBar.alpha = 0
            viewModel.showNavigationButtons.onNext(false)
            navigationItem.titleView = searchBar
            navigationController?.navigationBar.sizeToFit()
            searchBar.becomeFirstResponder()
            UIView.animate(withDuration: 0.4, animations: {
                self.searchBar.alpha = 1
            })
        }
        else {
            searchBar.resignFirstResponder()
            UIView.animate(withDuration: 0.2, animations: {
                self.searchBar.alpha = 0
            }, completion: { _ in
                self.viewModel.showNavigationButtons.onNext(true)
                self.navigationItem.titleView = nil
                self.navigationController?.navigationBar.sizeToFit()
            })
        }
    }
}


extension SitesTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel.filterAction.onNext(false)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.filterAction.onNext(false)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let index = SelectedScope(rawValue: searchBar.selectedScopeButtonIndex) else { return }
        viewModel.handleTextChange(searchText: searchText, index: index)
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        guard let searchText = searchBar.text, let index = SelectedScope(rawValue: selectedScope) else { return }
        viewModel.handleTextChange(searchText: searchText, index: index)
    }
}
