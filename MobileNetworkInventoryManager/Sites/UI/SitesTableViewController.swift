//
//  SitesTableViewController.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 27/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public class SitesTableViewController: UITableViewController {

    private let viewModel: SitesViewModel
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
        searchBar.scopeButtonTitles = [R.string.localizable.scope_name(), R.string.localizable.scope_address(), R.string.localizable.scope_tech(), R.string.localizable.scope_mark()]
        searchBar.showsScopeBar = true
        searchBar.showsCancelButton = true
        searchBar.sizeToFit()
        return searchBar
    }()
    
    public init(viewModel: SitesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        printDeinit()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        initializeVM()
        searchBar.delegate = self
        viewModel.input.sitesSubject.onNext(())
        viewModel.setupSortView(frame: view.frame)
        viewModel.output.showNavigationButtons.onNext(true)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent{
            viewModel.dependecies.coordinatorDelegate?.viewControllerHasFinished()
        }
    }
}

private extension SitesTableViewController {
    func setupLayout() {
        if #available(iOS 13.0, *) {
            UITextField.appearance(whenContainedInInstancesOf: [type(of: searchBar)]).tintColor = .white
        }
        else {
            UITextField.appearance(whenContainedInInstancesOf: [type(of: searchBar)]).tintColor = .darkGray
        }
        view.backgroundColor = .white
        navigationItem.title = R.string.localizable.sites()
        setupTable()
    }
    
    func setupTable() {
        tableView.register(CardTableViewCell.self, forCellReuseIdentifier: CardTableViewCell.identifier)
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.refreshControl = myRefreshControl
    }
    
    func showNavigationButtons(shouldShow: Bool) {
        if shouldShow {
            navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(handleShowSearchBar)), animated: true)
            navigationItem.setLeftBarButton(UIBarButtonItem(image: #imageLiteral(resourceName: "sort"), style: .plain, target: self, action: #selector(openSortOptions)), animated: true)
        }
        else {
            navigationItem.setRightBarButton(nil, animated: true)
            navigationItem.setLeftBarButton(nil, animated: true)
        }
    }
    
    func showSearchBar(shouldShow: Bool) {
        if shouldShow {
            searchBar.alpha = 0
            viewModel.output.showNavigationButtons.onNext(false)
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
                self.viewModel.output.showNavigationButtons.onNext(true)
                self.navigationItem.titleView = nil
                self.navigationController?.navigationBar.sizeToFit()
            })
        }
    }
    
    @objc func handleShowSearchBar() {
        viewModel.output.filterAction.onNext(true)
    }
    
    @objc func openSortOptions() {
        viewModel.output.sortView.show()
    }
}


private extension SitesTableViewController {
    func initializeVM() {
        let input = SitesViewModel.Input(sitesSubject: ReplaySubject.create(bufferSize: 1), siteDetailsSubject: PublishSubject())
        let output = viewModel.transform(input: input)
        disposeBag.insert(output.disposables)
        initializeErrorObserver(for: output.alertOfError)
        initializeRefreshObserver()
        initializeEndRefreshingObserver(for: output.endRefreshing)
        subscribeToScreenData()
        initializeFilterActionObserver(for: output.filterAction)
        initializeNavigationButtonsObserver(for: output.showNavigationButtons)
        initializeResignResponderObserver(for: output.resignResponder)
    }
    
    func initializeErrorObserver(for subject: PublishSubject<LoadError>) {
        subject
        .asDriver(onErrorJustReturn: .failedLoad(text: .empty))
        .do(onNext: { [unowned self] (error) in
            let alert: UIAlertController
            switch error {
            case .failedLoad(let text):
                alert = getAlert(title: R.string.localizable.error_alert_title(), message: R.string.localizable.error_alert_message(text), actionTitle: R.string.localizable.alert_ok_action())
            }
            self.present(alert, animated: true, completion: nil)
        })
        .drive()
        .disposed(by: disposeBag)
    }
    
    func initializeRefreshObserver() {
        myRefreshControl.rx.controlEvent(.valueChanged)
        .asObservable()
        .subscribe(onNext: { [unowned self] in
            self.viewModel.input.sitesSubject.onNext(())
        }).disposed(by: disposeBag)
    }
    
    func initializeEndRefreshingObserver(for subject: PublishSubject<()>) {
        subject
        .observeOn(MainScheduler.instance)
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        .subscribe(onNext: { [unowned self] in
            self.myRefreshControl.endRefreshing()
        })
        .disposed(by: disposeBag)
    }
    
    func subscribeToScreenData() {
        viewModel.output.filteredSitesPreviews
        .observeOn(MainScheduler.instance)
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        .subscribe(onNext: { [unowned self] (_) in
            self.tableView.reloadData()
        })
        .disposed(by: disposeBag)
    }
    
    func initializeFilterActionObserver(for subject: PublishSubject<Bool>) {
        subject
        .asDriver(onErrorJustReturn: false)
        .do(onNext: { [unowned self] shouldShow in
            self.showSearchBar(shouldShow: shouldShow)
        })
        .drive()
        .disposed(by: disposeBag)
    }
    
    func initializeNavigationButtonsObserver(for subject: PublishSubject<Bool>) {
        subject
        .asDriver(onErrorJustReturn: false)
        .do(onNext: { [unowned self] shouldShow in
            self.showNavigationButtons(shouldShow: shouldShow)
        })
        .drive()
        .disposed(by: disposeBag)
    }
    
    func initializeResignResponderObserver(for subject: PublishSubject<()>) {
        subject
        .observeOn(MainScheduler.instance)
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        .subscribe(onNext: { [unowned self] in
            self.searchBar.resignFirstResponder()
        })
        .disposed(by: disposeBag)
    }
}

extension SitesTableViewController {
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.output.filteredSitesPreviews.value.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CardTableViewCell.identifier, for: indexPath) as? CardTableViewCell else{
            fatalError(R.string.localizable.cell_error(CardTableViewCell.identifier))
        }
        
        let site = viewModel.output.filteredSitesPreviews.value[indexPath.row]
        cell.configure(site)
        
        cell.onCellClicked = { [unowned self] in
            self.viewModel.output.resignResponder.onNext(())
            self.viewModel.input.siteDetailsSubject.onNext(site)
        }

        return cell
    }
}

extension SitesTableViewController: UISearchBarDelegate {
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel.output.filterAction.onNext(false)
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.output.filterAction.onNext(false)
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let index = SitesSelectedScope(rawValue: searchBar.selectedScopeButtonIndex) else { return }
        viewModel.handleTextChange(searchText: searchText, index: index)
    }
    
    public func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        guard let searchText = searchBar.text, let index = SitesSelectedScope(rawValue: selectedScope) else { return }
        viewModel.handleTextChange(searchText: searchText, index: index)
    }
}
