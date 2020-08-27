//
//  TasksViewController.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 06/06/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TasksViewController: UIViewController, AlertView {

    private let viewModel: TasksViewModel
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
        if #available(iOS 13.0, *) {
            control.backgroundColor = .systemBlue
            control.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.systemBlue], for: .selected)
            control.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        }
        control.addTarget(self, action: #selector(handleSegmentChange), for: .valueChanged)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(CardTableViewCell.self, forCellReuseIdentifier: CardTableViewCell.identifier)
        table.estimatedRowHeight = UITableView.automaticDimension
        table.rowHeight = UITableView.automaticDimension
        table.backgroundColor = .white
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    public init(viewModel: TasksViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        printDeinit()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        initializeVM()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = myRefreshControl
        viewModel.setupSortView(frame: view.frame)
        viewModel.input.loadDataSubject.onNext(())
        viewModel.output.showNavigationButtons.onNext(true)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent{
            viewModel.dependecies.coordinatorDelegate?.viewControllerHasFinished()
        }
    }
}

private extension TasksViewController {
    func setup() {
        if #available(iOS 13.0, *) {
            UITextField.appearance(whenContainedInInstancesOf: [type(of: searchBar)]).tintColor = .white
        }
        else {
            UITextField.appearance(whenContainedInInstancesOf: [type(of: searchBar)]).tintColor = .darkGray
        }
        view.backgroundColor = .white
        navigationItem.title = R.string.localizable.tasks()
        setupLayout()
    }
    
    func setupLayout() {
        view.addSubviews(segmentedControl, tableView)
        setConstraints()
    }
    
    func setConstraints() {
        segmentedControl.snp.makeConstraints { (maker) in
            maker.top.leading.trailing.equalToSuperview().inset(16)
        }
        
        tableView.snp.makeConstraints { (maker) in
            maker.top.equalTo(segmentedControl.snp.bottom).offset(16)
            maker.leading.trailing.bottom.equalToSuperview()
        }
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
            viewModel.output.showNavigationButtons.onNext(false)
            navigationItem.titleView = searchBar
            navigationController?.navigationBar.sizeToFit()
            searchBar.becomeFirstResponder()
            segmentedControl.isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.4, animations: {
                self.searchBar.alpha = 1
            })
        }
        else {
            searchBar.resignFirstResponder()
            segmentedControl.isUserInteractionEnabled = true
            UIView.animate(withDuration: 0.2, animations: {
                self.searchBar.alpha = 0
            }, completion: { _ in
                self.viewModel.output.showNavigationButtons.onNext(true)
                self.navigationItem.titleView = nil
                self.navigationController?.navigationBar.sizeToFit()
            })
        }
    }
    
    @objc private func handleShowSearchBar() {
        viewModel.output.filterAction.onNext(true)
    }
    
    @objc private func openSortOptions() {
        viewModel.output.sortView.show()
    }
    
    @objc private func handleSegmentChange() {
        viewModel.handleSegmentedOptionChange(index: segmentedControl.selectedSegmentIndex)
    }
    
    private func setupSegmentedControl() {
        segmentedControl.removeAllSegments()
        for (index, item) in viewModel.getSegmentedOptions().enumerated() {
            segmentedControl.insertSegment(withTitle: item, at: index, animated: false)
        }
        segmentedControl.selectedSegmentIndex = viewModel.segmentedIndex
    }
}

private extension TasksViewController {
    func initializeVM() {
        let input = TasksViewModel.Input(loadDataSubject: ReplaySubject.create(bufferSize: 1), taskDetailsSubject: PublishSubject())
        let output = viewModel.transform(input: input)
        disposeBag.insert(output.disposables)
        initializeErrorObserver(for: output.alertOfError)
        initializeRefreshObserver()
        initializeEndRefreshingObserver(for: output.endRefreshing)
        subscribeToScreenData()
        initializeSegmentedControlObserver(for: output.setupSegmentedControl)
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
                alert = self.getAlert(title: R.string.localizable.error_alert_title(), message: R.string.localizable.error_alert_message(text), actionTitle: R.string.localizable.alert_ok_action())
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
            self.viewModel.input.loadDataSubject.onNext(())
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
        viewModel.output.filteredTasksPreviews
        .observeOn(MainScheduler.instance)
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        .subscribe(onNext: { [unowned self] (_) in
            self.tableView.reloadData()
        })
        .disposed(by: disposeBag)
    }
    
    func initializeSegmentedControlObserver(for subject: PublishSubject<()>) {
        subject
        .observeOn(MainScheduler.instance)
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        .subscribe(onNext: { [unowned self] in
            self.setupSegmentedControl()
            self.handleSegmentChange()
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

extension TasksViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.output.filteredTasksPreviews.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CardTableViewCell.identifier, for: indexPath) as? CardTableViewCell else{
            fatalError(R.string.localizable.cell_error(CardTableViewCell.identifier))
        }
        
        let task = viewModel.output.filteredTasksPreviews.value[indexPath.row]
        cell.configure(task)
        
        cell.onCellClicked = { [weak self] in
            self?.viewModel.output.resignResponder.onNext(())
            self?.viewModel.input.taskDetailsSubject.onNext(task)
        }
        
        return cell
    }
}

extension TasksViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel.output.filterAction.onNext(false)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.output.filterAction.onNext(false)
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
