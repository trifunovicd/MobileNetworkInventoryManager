//
//  DetailsViewModel.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 06/06/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation

public class DetailsViewModel: ViewModelType {
    
    public struct Input {
        let loadDataSubject: ReplaySubject<()>
        let completeTaskSubject: PublishSubject<Int>
    }
    
    public struct Output {
        var disposables: [Disposable]
        var shouldFollowUser: Bool = false
        var taskId: Int = -1
        let alertOfError: PublishSubject<()>
        let closeModal: PublishSubject<()>
        let addSiteMarker: PublishSubject<()>
        let centerMapView: PublishSubject<CLLocationCoordinate2D>
        let updateDistance: PublishSubject<CLLocationCoordinate2D>
        var screenData: BehaviorRelay<[SectionItem<DetailsSectionType, DetailsItemType, ItemDetails>]>
    }
    
    public struct Dependecies {
        let subscribeScheduler: SchedulerType
        weak var tasksCoordinatorDelegate: ModalDelegate?
        let taskRepository: TaskRepository
        var details: Details!
        let locationService: LocationService
        let screenType: DetailsScreenType
    }
    
    public init(dependecies: Dependecies) {
        self.dependecies = dependecies
        NotificationCenter.default.addObserver(self, selector: #selector(listenForLocationUpdates(_:)), name: NSNotification.Name(rawValue: R.string.localizable.notification_name()), object: dependecies.locationService)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: R.string.localizable.notification_name()), object: dependecies.locationService)
    }

    var input: Input!
    var output: Output!
    var dependecies: Dependecies
    
    public func transform(input: Input) -> Output {
        var disposables = [Disposable]()
        disposables.append(initializeLoadDataObservable(for: input.loadDataSubject))
        disposables.append(initializeCompleteTaskObservable(for: input.completeTaskSubject))
        let output = Output(disposables: disposables, alertOfError: PublishSubject(), closeModal: PublishSubject(), addSiteMarker: PublishSubject(), centerMapView: PublishSubject(), updateDistance: PublishSubject(), screenData: BehaviorRelay.init(value: []))
        
        self.input = input
        self.output = output
        
        return output
    }
    
    @objc private func listenForLocationUpdates(_ notification: NSNotification) {
        guard let dict = notification.userInfo as NSDictionary?, let locations = dict[R.string.localizable.notification_info()] as? [CLLocation], let location = locations.last else { return }
        
        output.updateDistance.onNext(location.coordinate)
        
        if output.shouldFollowUser {
            output.centerMapView.onNext(location.coordinate)
        }
    }
}

private extension DetailsViewModel {
    func initializeLoadDataObservable(for subject: ReplaySubject<()>) -> Disposable {
        return subject.map {[unowned self] (_) -> [SectionItem<DetailsSectionType, DetailsItemType, ItemDetails>] in
            return self.createScreenData(self.dependecies.screenType, details: self.dependecies.details)
        }
        .observeOn(MainScheduler.instance)
        .subscribeOn(dependecies.subscribeScheduler)
        .subscribe(onNext: { [unowned self] (items) in
            self.output.screenData.accept(items)
        })
    }
    
    func createScreenData(_ screenType: DetailsScreenType, details: Details) -> [SectionItem<DetailsSectionType, DetailsItemType, ItemDetails>]{
        switch screenType {
        case .site:
            guard let siteDetails = details as? SiteDetails else {return []}
            return getSiteScreenData(details: siteDetails)
        case .task:
            guard let taskDetails = details as? TaskDetails else {return []}
            return getTaskScreenData(details: taskDetails)
        }
    }

    
    func getSiteScreenData(details: SiteDetails) -> [SectionItem<DetailsSectionType, DetailsItemType, ItemDetails>] {
        let rows: [RowItem<DetailsItemType, ItemDetails>] = [
            RowItem(type: .details, data: ItemDetails(label: R.string.localizable.site_mark(), text: details.siteMark)),
            RowItem(type: .details, data: ItemDetails(label: R.string.localizable.site_name(), text: details.siteName)),
            RowItem(type: .details, data: ItemDetails(label: R.string.localizable.site_address(), text: details.siteAddress)),
            RowItem(type: .details, data: ItemDetails(label: R.string.localizable.site_tech(), text: details.siteTechnology)),
            RowItem(type: .details, data: ItemDetails(label: R.string.localizable.site_power(), text: details.sitePowerSupply)),
            RowItem(type: .details, data: ItemDetails(label: R.string.localizable.site_directions(), text: details.siteDirections))]
        
        return [SectionItem<DetailsSectionType, DetailsItemType, ItemDetails>(type: .site, items: rows, headerTitle: R.string.localizable.site_details())]
    }
    
    func getTaskScreenData(details: TaskDetails) -> [SectionItem<DetailsSectionType, DetailsItemType, ItemDetails>] {
        let siteRows: [RowItem<DetailsItemType, ItemDetails>] = [
            RowItem(type: .details, data: ItemDetails(label: R.string.localizable.site_mark(), text: details.siteMark)),
            RowItem(type: .details, data: ItemDetails(label: R.string.localizable.site_name(), text: details.siteName)),
            RowItem(type: .details, data: ItemDetails(label: R.string.localizable.site_address(), text: details.siteAddress)),
            RowItem(type: .details, data: ItemDetails(label: R.string.localizable.site_tech(), text: details.siteTechnology)),
            RowItem(type: .details, data: ItemDetails(label: R.string.localizable.site_power(), text: details.sitePowerSupply)),
            RowItem(type: .details, data: ItemDetails(label: R.string.localizable.site_directions(), text: details.siteDirections))]
        
        let taskOpeningTime = !details.taskOpeningTime.isEmpty ? details.taskOpeningTime : "-"
        let taskClosingTime = !details.taskClosingTime.isEmpty ? details.taskClosingTime : "-"
        let taskRows: [RowItem<DetailsItemType, ItemDetails>] = [
            RowItem(type: .details, data: ItemDetails(label: R.string.localizable.task_opening_time(), text: taskOpeningTime)),
            RowItem(type: .details, data: ItemDetails(label: R.string.localizable.task_closing_time(), text: taskClosingTime)),
            RowItem(type: .details, data: ItemDetails(label: R.string.localizable.task_status(), text: details.taskStatusName)),
            RowItem(type: .details, data: ItemDetails(label: R.string.localizable.task_category(), text: details.taskCategoryName)),
            RowItem(type: .details, data: ItemDetails(label: R.string.localizable.task_description(), text: details.taskDescription))]
        
        return [
            SectionItem<DetailsSectionType, DetailsItemType, ItemDetails>(type: .task, items: taskRows, headerTitle: R.string.localizable.task_details()),
            SectionItem<DetailsSectionType, DetailsItemType, ItemDetails>(type: .site, items: siteRows, headerTitle: R.string.localizable.site_details())]
    }
}

private extension DetailsViewModel {
    func initializeCompleteTaskObservable(for subject: PublishSubject<Int>) -> Disposable {
        return subject.flatMap {[unowned self] (taskId) -> Observable<Int> in
            return self.dependecies.taskRepository.setTaskStatus(taskId: taskId)
        }
        .observeOn(MainScheduler.instance)
        .subscribeOn(dependecies.subscribeScheduler)
        .subscribe(onNext: { [unowned self] (result) in
            if result == 1 {
                self.dependecies.tasksCoordinatorDelegate?.getTasks()
            } else {
                self.output.alertOfError.onNext(())
            }
        })
    }
}
