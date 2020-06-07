//
//  TasksViewModel.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 20/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import CoreLocation

class TasksViewModel {
    weak var tasksCoordinatorDelegate: TasksCoordinator?
    var sortView: SortView!
    var filterText: String = ""
    var filterIndex: TasksSelectedScope = .name
    var segmentedIndex: Int = 0
    var userId: Int!
    var tasks: [Task] = []
    var tasksPreviews: [TaskPreview] = []
    var segmentedTasksPreviews: [TaskPreview] = []
    var filteredTasksPreviews: [TaskPreview] = []
    var taskStatusList: [TaskStatus] = []
    let tasksRequest = PublishSubject<Void>()
    let fetchFinished = PublishSubject<Void>()
    let alertOfError = PublishSubject<Void>()
    let setupSegmentedControl = PublishSubject<Void>()
    let filterAction = PublishSubject<Bool>()
    let showNavigationButtons = PublishSubject<Bool>()
    let endRefreshing = PublishSubject<Void>()
    
    func initialize() -> Disposable{
        tasksRequest
            .asObservable()
            .flatMap(getTasksObservale)
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .success(let data):
                    self?.tasks = data.0
                    self?.tasksPreviews = data.1
                    self?.taskStatusList = data.2
                    self?.endRefreshing.onNext(())
                    self?.setupSegmentedControl.onNext(())
                case .failure(let error):
                    print(error)
                    self?.endRefreshing.onNext(())
                    self?.alertOfError.onNext(())
                }
            })
    }
    
    private func getTasksObservale() -> Observable<Result<([Task], [TaskPreview], [TaskStatus]), Error>> {
        let tasksObservable: Observable<[Task]> = getRequest(url: makeUrl(action: .getTasksForUser, userId: userId))
        let userObservable: Observable<[User]> = getRequest(url: makeUrl(action: .getUserData, userId: userId))
        let statusObservable: Observable<[TaskStatus]> = getRequest(url: makeUrl(action: .getTaskStatus, userId: nil))
        
        var previews: [TaskPreview] = []
        
        return Observable.combineLatest(tasksObservable, userObservable, statusObservable, resultSelector: { tasks, user, statusList in
            
            for task in tasks {
                let taskPreview = TaskPreview(taskId: task.task_id, taskCategoryName: task.task_category_name, siteMark: task.site_mark, siteName: task.site_name, taskOpeningTime: task.task_opening_time.getDateFromString(), distance: getDistance(userLocation: (user[0].lat, user[0].lng), siteLocation: (task.site_lat, task.site_lng)), taskStatus: task.task_status)
                
                previews.append(taskPreview)
            }
            return (tasks, previews, statusList)
            
        }).map { (data) -> Result<([Task], [TaskPreview], [TaskStatus]), Error> in
            return Result.success(data)
            
        }.catchError { error -> Observable<Result<([Task], [TaskPreview], [TaskStatus]), Error>> in
            let result = Result<([Task], [TaskPreview], [TaskStatus]), Error>.failure(error)
            return Observable.just(result)
        }
    }
    
    
    func showTaskDetails(taskPreview: TaskPreview) {
        for task in tasks {
            if task.task_id == taskPreview.taskId {
                var openingTime: String = ""
                var closingTime: String = ""
                if let opening = taskPreview.taskOpeningTime {
                    openingTime = opening.getStringFromDate()
                }
                if let sClosing = task.task_closing_time, let dClosing = sClosing.getDateFromString() {
                    closingTime = dClosing.getStringFromDate()
                }
                let taskDetails = TaskDetails(taskId: task.task_id, siteMark: task.site_mark, siteName: task.site_name, siteAddress: task.site_address, siteTechnology: getTechnology(is2GAvailable: task.is_2G_available, is3GAvailable: task.is_3G_available, is4GAvailable: task.is_4G_available), siteDistance: taskPreview.distance, siteLat: task.site_lat, siteLng: task.site_lng, siteDirections: task.site_directions, sitePowerSupply: task.site_power_supply, taskDescription: task.task_description, taskCategoryName: task.task_category_name, taskStatusName: task.task_status_name, taskOpeningTime: openingTime, taskClosingTime: closingTime)

                tasksCoordinatorDelegate?.openTaskDetails(taskDetails: taskDetails)
                break
            }
        }
    }
    
    func getSegmentedOptions() -> [String]{
        var options: [String] = []
        for status in taskStatusList {
            options.append(status.name)
        }
        return options
    }
    
    func handleSegmentedOptionChange(index: Int) {
        segmentedTasksPreviews = tasksPreviews.filter({ (task) -> Bool in
            return task.taskStatus == taskStatusList[index].status_id
        })
        
        segmentedIndex = index
        getSortSettings()
    }
    
    func setupSortView(frame: CGRect) {
        let sortViewModel = SortViewModel(frame: frame, delegate: self, sortType: .tasks)
        sortView = SortView(viewModel: sortViewModel)
    }
    
    func handleTextChange(searchText: String, index: TasksSelectedScope) {
        if searchText.isEmpty {
            filteredTasksPreviews = segmentedTasksPreviews
        }
        else {
            filterTableView(index: index, text: searchText)
        }

        filterText = searchText
        filterIndex = index
        
        fetchFinished.onNext(())
    }
    
    private func filterTableView(index: TasksSelectedScope, text: String) {
        switch index {
        case .name:
            filteredTasksPreviews = segmentedTasksPreviews.filter({ (task) -> Bool in
                return task.siteName.lowercased().contains(text.lowercased())
            })
        case .task:
            filteredTasksPreviews = segmentedTasksPreviews.filter({ (task) -> Bool in
                return task.taskCategoryName.lowercased().contains(text.lowercased())
            })
        case .date:
            filteredTasksPreviews = segmentedTasksPreviews.filter({ (task) -> Bool in
                guard let openingTime = task.taskOpeningTime else {return false}
                return openingTime.getStringFromDate().lowercased().contains(text.lowercased())
            })
        case .mark:
            filteredTasksPreviews = segmentedTasksPreviews.filter({ (task) -> Bool in
                return task.siteMark.lowercased().contains(text.lowercased())
            })
        }
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
        sortSitesBy(value: sortSettings.value, order: order)
        sortView.viewModel.settings = (sortSettings.value, sortSettings.order)
    }
    
    private func sortSitesBy(value: Int, order: Order) {
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


extension TasksViewModel: SortDelegate {
    func sortBy(value: Int, order: Int) {
        setSortSettings(value: value, order: order)
    }
}
