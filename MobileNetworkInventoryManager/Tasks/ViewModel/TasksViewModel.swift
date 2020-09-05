//
//  TasksViewModel.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 20/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import CoreLocation

public class TasksViewModel: ViewModelType, TransformData {
    
    public struct Input {
        let loadDataSubject: ReplaySubject<()>
        let taskDetailsSubject: PublishSubject<TaskPreview>
    }
    
    public struct Output {
        var disposables: [Disposable]
        let alertOfError: PublishSubject<LoadError>
        var filteredTasksPreviews: BehaviorRelay<[TaskPreview]>
        var sortView: SortView!
        let filterAction: PublishSubject<Bool>
        let showNavigationButtons: PublishSubject<Bool>
        let endRefreshing: PublishSubject<()>
        let resignResponder: PublishSubject<()>
        let setupSegmentedControl: PublishSubject<()>
    }
    
    public struct Dependecies {
        let subscribeScheduler: SchedulerType
        weak var coordinatorDelegate: CoordinatorDelegate?
        weak var taskDetailsDelegate: TaskDetailsDelegate?
        weak var modalDelegate: ModalDelegate?
        let userRepository: UserRepository
        let taskRepository: TaskRepository
        var userId: Int!
    }
    
    public init(dependecies: Dependecies) {
        self.dependecies = dependecies
    }

    var input: Input!
    var output: Output!
    var dependecies: Dependecies
    
    var tasks: [Task] = []
    var tasksPreviews: [TaskPreview] = []
    var segmentedTasksPreviews: [TaskPreview] = []
    var taskStatusList: [TaskStatus] = []
    var filterText: String = ""
    var filterIndex: TasksSelectedScope = .name
    var segmentedIndex: Int = 0
    
    public func transform(input: Input) -> Output {
        var disposables = [Disposable]()
        disposables.append(initializeLoadDataObservable(for: input.loadDataSubject))
        disposables.append(initializeTaskDetailsObservable(for: input.taskDetailsSubject))
        let output = Output(disposables: disposables, alertOfError: PublishSubject(), filteredTasksPreviews: BehaviorRelay.init(value: []), filterAction: PublishSubject(), showNavigationButtons: PublishSubject(), endRefreshing: PublishSubject(), resignResponder: PublishSubject(), setupSegmentedControl: PublishSubject())
        
        self.input = input
        self.output = output
        
        return output
    }
    
    func setupSortView(frame: CGRect) {
        let sortViewModel = SortViewModel(dependecies: SortViewModel.Dependecies(subscribeScheduler: ConcurrentDispatchQueueScheduler(qos: .background), delegate: self, sortType: .tasks, frame: frame))
        output.sortView = SortView(viewModel: sortViewModel)
    }
    
    func getTaskStatusList(data: [TaskStatus]) -> [TaskStatus] {
        var statusList = [TaskStatus(status_id: 0, name: Status.all.getTitle())]
        statusList.append(contentsOf: data)
        return statusList
    }
}

private extension TasksViewModel {
    func initializeLoadDataObservable(for subject: ReplaySubject<()>) -> Disposable {
        return subject.flatMap {[unowned self] (_) -> Observable<DataWrapper<([Task], [TaskPreview], [TaskStatus])>> in
            return self.combineObservables(tasksObservable: self.dependecies.taskRepository.getTasks(userId: self.dependecies.userId), userObservable: self.dependecies.userRepository.getUserData(userId: self.dependecies.userId), statusObservable: self.dependecies.taskRepository.getTaskStatuses())
        }
        .observeOn(MainScheduler.instance)
        .subscribeOn(dependecies.subscribeScheduler)
        .subscribe(onNext: { [unowned self] (dataWrapper) in
            guard let safeData = dataWrapper.data else {
                self.output.endRefreshing.onNext(())
                self.dependecies.modalDelegate?.dismissModal()
                self.handleError(error: dataWrapper.error)
                return
            }
            self.tasks = safeData.0
            self.tasksPreviews = safeData.1
            self.taskStatusList = self.getTaskStatusList(data: safeData.2)
            self.output.endRefreshing.onNext(())
            self.output.setupSegmentedControl.onNext(())
            self.dependecies.modalDelegate?.dismissModal()
        })
    }
    
    func combineObservables(tasksObservable: Observable<DataWrapper<[Task]>>, userObservable: Observable<DataWrapper<[User]>>, statusObservable: Observable<DataWrapper<[TaskStatus]>>) -> Observable<DataWrapper<([Task], [TaskPreview], [TaskStatus])>> {
            
            return Observable<DataWrapper<([Task], [TaskPreview], [TaskStatus])>>.combineLatest(tasksObservable, userObservable, statusObservable, resultSelector: { tasksWrapper, userWrapper, statusListWrapper in
                
                var previews: [TaskPreview] = []
                
                if let tasks = tasksWrapper.data, let user = userWrapper.data, let statusList = statusListWrapper.data {
                    for task in tasks {
                        let taskPreview = TaskPreview(taskId: task.task_id, taskCategoryName: task.task_category_name, siteMark: task.site_mark, siteName: task.site_name, taskOpeningTime: task.task_opening_time.getDateFromString(), taskClosingTime: task.task_closing_time?.getDateFromString(), distance: self.getDistance(userLocation: (user[0].lat, user[0].lng), siteLocation: (task.site_lat, task.site_lng)), taskStatus: task.task_status)
                        
                        previews.append(taskPreview)
                    }
                    return DataWrapper(data: (tasks, previews, statusList), error: nil)
                }
                guard let tasksNetError = tasksWrapper.error as? NetworkError,
                    let userNetError = userWrapper.error as? NetworkError,
                    let statusListNetError = statusListWrapper.error as? NetworkError,
                    tasksNetError == .notConnectedToInternet || userNetError == .notConnectedToInternet || statusListNetError == .notConnectedToInternet else {
                        return DataWrapper(data: nil, error: NetworkError.noDataAvailable)
                }
                return DataWrapper(data: nil, error: NetworkError.notConnectedToInternet)
            })
        }
    
    func handleError(error: Error?) {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .notConnectedToInternet:
                self.output.alertOfError.onNext(.failedLoad(text: R.string.localizable.no_internet_connection()))
            default:
                self.output.alertOfError.onNext(.failedLoad(text: .empty))
            }
        } else {
            self.output.alertOfError.onNext(.failedLoad(text: .empty))
        }
    }
}

private extension TasksViewModel {
    private func getSortSettings() {
        do {
            let realm = try Realm()
            
            let settings = realm.object(ofType: TaskSortSettings.self, forPrimaryKey: R.string.localizable.task_sort_key())
            
            if let sortSettings = settings {
                applySettings(sortSettings: sortSettings)
            }
            else {
                let sortSettings = TaskSortSettings()
                applySettings(sortSettings: sortSettings)
            }
        } catch  {
            print(error)
        }
    }
    
    private func applySettings(sortSettings: TaskSortSettings) {
        guard let order = Order(rawValue: sortSettings.order) else { return }
        sortTasksBy(value: sortSettings.value, order: order)
        output.sortView.viewModel.output.settings = (sortSettings.value, sortSettings.order)
    }
    
    private func sortTasksBy(value: Int, order: Order) {
        switch value {
        case TasksSortType.date.rawValue:
            sortByDate(order: order)
        case TasksSortType.mark.rawValue:
            sortByMark(order: order)
        case TasksSortType.name.rawValue:
            sortByName(order: order)
        case TasksSortType.task.rawValue:
            sortByTask(order: order)
        case TasksSortType.distance.rawValue:
            sortByDistance(order: order)
        default:
            sortByDate(order: order)
        }
        
        handleTextChange(searchText: filterText, index: filterIndex)
    }
    
    private func sortByDate(order: Order) {
        if order == .ascending {
            segmentedTasksPreviews = segmentedTasksPreviews.sorted(by: { (task1, task2) -> Bool in
                guard let openingTime1 = task1.taskOpeningTime, let openingTime2 = task2.taskOpeningTime else {return false}
                return openingTime1 < openingTime2
            })
        }
        else {
            segmentedTasksPreviews = segmentedTasksPreviews.sorted(by: { (task1, task2) -> Bool in
                guard let openingTime1 = task1.taskOpeningTime, let openingTime2 = task2.taskOpeningTime else {return false}
                return openingTime1 > openingTime2
            })
        }
    }
    
    private func sortByMark(order: Order) {
        if order == .ascending {
            segmentedTasksPreviews = segmentedTasksPreviews.sorted(by: { (task1, task2) -> Bool in
                return task1.siteMark < task2.siteMark
            })
        }
        else {
            segmentedTasksPreviews = segmentedTasksPreviews.sorted(by: { (task1, task2) -> Bool in
                return task1.siteMark > task2.siteMark
            })
        }
    }
    
    private func sortByName(order: Order) {
        if order == .ascending {
            segmentedTasksPreviews = segmentedTasksPreviews.sorted(by: { (task1, task2) -> Bool in
                return task1.siteName < task2.siteName
            })
        }
        else {
            segmentedTasksPreviews = segmentedTasksPreviews.sorted(by: { (task1, task2) -> Bool in
                return task1.siteName > task2.siteName
            })
        }
    }
    
    private func sortByTask(order: Order) {
        if order == .ascending {
            segmentedTasksPreviews = segmentedTasksPreviews.sorted(by: { (task1, task2) -> Bool in
                return task1.taskCategoryName < task2.taskCategoryName
            })
        }
        else {
            segmentedTasksPreviews = segmentedTasksPreviews.sorted(by: { (task1, task2) -> Bool in
                return task1.taskCategoryName > task2.taskCategoryName
            })
        }
    }
    
    private func sortByDistance(order: Order) {
        if order == .ascending {
            segmentedTasksPreviews = segmentedTasksPreviews.sorted(by: { (task1, task2) -> Bool in
                return task1.distance < task2.distance
            })
        }
        else {
            segmentedTasksPreviews = segmentedTasksPreviews.sorted(by: { (task1, task2) -> Bool in
                return task1.distance > task2.distance
            })
        }
    }
}

private extension TasksViewModel {
    func initializeTaskDetailsObservable(for subject: PublishSubject<TaskPreview>) -> Disposable{
        return subject
        .observeOn(MainScheduler.instance)
        .subscribeOn(dependecies.subscribeScheduler)
        .subscribe(onNext: {[unowned self] (taskPreview) in
            self.showTaskDetails(taskPreview: taskPreview)
        })
    }
    
    func showTaskDetails(taskPreview: TaskPreview) {
        for task in tasks {
            if task.task_id == taskPreview.taskId {
                var openingTime: String = ""
                var closingTime: String = ""
                if let opening = taskPreview.taskOpeningTime {
                    openingTime = opening.getStringFromDate()
                }
                if let closing = taskPreview.taskClosingTime {
                    closingTime = closing.getStringFromDate()
                }
                let taskDetails = TaskDetails(siteId: task.site_id, siteMark: task.site_mark, siteName: task.site_name, siteAddress: task.site_address, siteTechnology: getTechnology(is2GAvailable: task.is_2G_available, is3GAvailable: task.is_3G_available, is4GAvailable: task.is_4G_available), siteDistance: taskPreview.distance, siteLat: task.site_lat, siteLng: task.site_lng, siteDirections: task.site_directions, sitePowerSupply: task.site_power_supply, taskId: task.task_id, taskDescription: task.task_description, taskCategoryName: task.task_category_name, taskStatusName: task.task_status_name, taskOpeningTime: openingTime, taskClosingTime: closingTime)
                dependecies.taskDetailsDelegate?.openTaskDetails(taskDetails: taskDetails)
                break
            }
        }
    }
}

public extension TasksViewModel {
    func getSegmentedOptions() -> [String]{
        var options: [String] = []
        var localizableOptions: [String] = []
        for status in taskStatusList {
            if let taskStatus = Status(rawValue: status.status_id) {
                localizableOptions.append(taskStatus.getTitle())
            }
            options.append(status.name)
        }
        if options.count == localizableOptions.count {
            return localizableOptions
        }
        return options
    }
    
    func handleSegmentedOptionChange(index: Int) {
        if index == Status.all.rawValue {
            segmentedTasksPreviews = tasksPreviews
        } else {
            segmentedTasksPreviews = tasksPreviews.filter({ (task) -> Bool in
                return task.taskStatus == taskStatusList[index].status_id
            })
        }
        
        segmentedIndex = index
        getSortSettings()
    }
}

public extension TasksViewModel {
    func handleTextChange(searchText: String, index: TasksSelectedScope) {
        if searchText.isEmpty {
            output.filteredTasksPreviews.accept(segmentedTasksPreviews)
        }
        else {
            filterTableView(index: index, text: searchText)
        }

        filterText = searchText
        filterIndex = index
    }
    
    private func filterTableView(index: TasksSelectedScope, text: String) {
        switch index {
        case .name:
            output.filteredTasksPreviews.accept(segmentedTasksPreviews.filter({ (task) -> Bool in
                    return task.siteName.lowercased().contains(text.lowercased())
            }))
        case .task:
            output.filteredTasksPreviews.accept(segmentedTasksPreviews.filter({ (task) -> Bool in
                return task.taskCategoryName.lowercased().contains(text.lowercased())
            }))
        case .date:
            output.filteredTasksPreviews.accept(segmentedTasksPreviews.filter({ (task) -> Bool in
                guard let openingTime = task.taskOpeningTime else {return false}
                return openingTime.getStringFromDate().lowercased().contains(text.lowercased())
            }))
        case .mark:
            output.filteredTasksPreviews.accept(segmentedTasksPreviews.filter({ (task) -> Bool in
                return task.siteMark.lowercased().contains(text.lowercased())
            }))
        }
    }
}

extension TasksViewModel: SortDelegate {
    public func sortBy(value: Int, order: Int) {
        setSortSettings(value: value, order: order)
    }
    
    private func setSortSettings(value: Int, order: Int) {
        let sortSettings = TaskSortSettings()
        sortSettings.value = value
        sortSettings.order = order
        
        do {
            let realm = try Realm()
            
            try realm.write {
                realm.add(sortSettings, update: .modified)
            }
            
            getSortSettings()
        } catch  {
            print(error)
        }
    }
}
