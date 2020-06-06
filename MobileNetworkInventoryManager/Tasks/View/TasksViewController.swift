//
//  TasksViewController.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 06/06/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

private let cellIdentifier = "TasksTableViewCell"

class TasksViewController: UIViewController {

    var viewModel: TasksViewModel!
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
        searchBar.scopeButtonTitles = [R.string.localizable.scope_name(), R.string.localizable.scope_task(), R.string.localizable.scope_date(), R.string.localizable.scope_mark()]
        searchBar.showsScopeBar = true
        searchBar.showsCancelButton = true
        searchBar.sizeToFit()
        return searchBar
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl()
        control.backgroundColor = .systemBlue
        control.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.systemBlue], for: .selected)
        control.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        control.addTarget(self, action: #selector(handleSegmentChange), for: .valueChanged)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(TasksTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()

        viewModel.initialize().disposed(by: disposeBag)
        viewModel.tasksRequest.onNext(())
    }
    
    private func setup() {
        if #available(iOS 13.0, *) {
            UITextField.appearance(whenContainedInInstancesOf: [type(of: searchBar)]).tintColor = .white
        }
        else {
            UITextField.appearance(whenContainedInInstancesOf: [type(of: searchBar)]).tintColor = .darkGray
        }
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = myRefreshControl
        
        setupLayout()
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
    
    @objc private func handleSegmentChange() {
        viewModel.handleSegmentedOptionChange(index: segmentedControl.selectedSegmentIndex)
    }
    
    private func setupSegmentedControl() {
        segmentedControl.removeAllSegments()
        for (index, item) in viewModel.getSegmentedOptions().enumerated() {
            segmentedControl.insertSegment(withTitle: item, at: index, animated: false)
        }
        segmentedControl.selectedSegmentIndex = 0
    }
    
    private func setupLayout() {
        view.addSubviews(views: [segmentedControl, tableView])
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setObservers() {
        myRefreshControl.rx.controlEvent(.valueChanged).asObservable().subscribe(onNext: { [weak self] in
            self?.viewModel.tasksRequest.onNext(())
        }).disposed(by: disposeBag)
        
        viewModel.endRefreshing.subscribe(onNext: { [weak self] in
            self?.myRefreshControl.endRefreshing()
        }).disposed(by: disposeBag)
        
        viewModel.fetchFinished.subscribe(onNext: { [weak self] in
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        viewModel.setupSegmentedControl.subscribe(onNext: { [weak self] in
            self?.setupSegmentedControl()
            self?.handleSegmentChange()
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


extension TasksViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.filteredTasksPreviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TasksTableViewCell else{
            fatalError(R.string.localizable.cell_error(cellIdentifier))
        }
        
        let task = viewModel.filteredTasksPreviews[indexPath.row]
        cell.configure(task)
        
        cell.onCellClicked = { [weak self] in
            self?.viewModel.showTaskDetails(taskPreview: task)
        }
        
        return cell
    }
    
}


extension TasksViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel.filterAction.onNext(false)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.filterAction.onNext(false)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let index = TasksSelectedScope(rawValue: searchBar.selectedScopeButtonIndex) else { return }
        viewModel.handleTextChange(searchText: searchText, index: index)
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        guard let searchText = searchBar.text, let index = TasksSelectedScope(rawValue: selectedScope) else { return }
        viewModel.handleTextChange(searchText: searchText, index: index)
    }
}
