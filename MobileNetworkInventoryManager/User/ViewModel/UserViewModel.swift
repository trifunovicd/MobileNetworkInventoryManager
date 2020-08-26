//
//  UserViewModel.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 20/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation
import RealmSwift

public class UserViewModel: ViewModelType {
    
    public struct Input {
        let loadDataSubject: ReplaySubject<()>
    }
    
    public struct Output {
        var disposables: [Disposable]
        let alertOfError: PublishSubject<LoadError>
        let addUserMarker: PublishSubject<()>
        let centerMapView: PublishSubject<CLLocationCoordinate2D>
        var screenData: BehaviorRelay<[SectionItem<DetailsSectionType, DetailsItemType, ItemDetails>]>
        var userData: UserPreview!
    }
    
    public struct Dependecies {
        let subscribeScheduler: SchedulerType
        weak var coordinatorDelegate: CoordinatorDelegate?
        let userRepository: UserRepository
        let locationService: LocationService
        var userId: Int!
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
    
    var shouldFollowUser: Bool = false
    
    public func transform(input: Input) -> Output {
        var disposables = [Disposable]()
        disposables.append(initializeLoadDataObservable(for: input.loadDataSubject))
        
        let output = Output(disposables: disposables, alertOfError: PublishSubject(), addUserMarker: PublishSubject(), centerMapView: PublishSubject(), screenData: BehaviorRelay.init(value: []))
        
        self.input = input
        self.output = output
        
        return output
    }
    
    @objc private func listenForLocationUpdates(_ notification: NSNotification) {
        guard let dict = notification.userInfo as NSDictionary?, let locations = dict[R.string.localizable.notification_info()] as? [CLLocation], let location = locations.last else { return }
        if shouldFollowUser {
            output.centerMapView.onNext(location.coordinate)
        }
    }
    
    func logout() {
        do {
            let realm = try Realm()
            
            try realm.write {
                realm.deleteAll()
            }
            dependecies.locationService.stop()
            dependecies.coordinatorDelegate?.viewControllerHasFinished()
        } catch  {
            print(error)
        }
    }
}

private extension UserViewModel {
    func initializeLoadDataObservable(for subject: ReplaySubject<()>) -> Disposable {
        return subject.flatMap {[unowned self] (_) -> Observable<DataWrapper<[User]>> in
            return self.dependecies.userRepository.getUserData(userId: self.dependecies.userId)
        }
        .flatMap({ (dataWrapper) -> Observable<DataWrapper<UserPreview>> in
            guard let safeData = dataWrapper.data else{
                return Observable.just(DataWrapper(data: nil, error: dataWrapper.error))
            }
            let user = safeData[0]
            let userPreview = UserPreview(name: user.name, surname: user.surname, username: user.username, lat: user.lat, lng: user.lng, recorded: user.recorded, distance: nil)
            return Observable.just(DataWrapper(data: userPreview, error: nil))
        })
        .map({ (dataWrapper) -> DataWrapper<([SectionItem<DetailsSectionType, DetailsItemType, ItemDetails>], UserPreview)> in
            guard let safeData = dataWrapper.data else{
                return DataWrapper(data: nil, error: dataWrapper.error)
            }
            let data = self.createScreenData(userData: safeData)
            return DataWrapper(data: (data, safeData), error: nil)
        })
        .observeOn(MainScheduler.instance)
        .subscribeOn(dependecies.subscribeScheduler)
        .subscribe(onNext: { [unowned self] (dataWrapper) in
            guard let safeData = dataWrapper.data else {
                self.handleError(error: dataWrapper.error)
                return
            }
            self.output.userData = safeData.1
            self.output.screenData.accept(safeData.0)
        })
    }
    
    func createScreenData(userData: UserPreview) -> [SectionItem<DetailsSectionType, DetailsItemType, ItemDetails>]{
        let rows: [RowItem<DetailsItemType, ItemDetails>] = [
            RowItem(type: .details, data: ItemDetails(label: R.string.localizable.user_name(), text: userData.name + " " + userData.surname)),
            RowItem(type: .details, data: ItemDetails(label: R.string.localizable.user_username(), text: userData.username)),
            RowItem(type: .details, data: ItemDetails(label: R.string.localizable.user_recorded(), text: userData.recorded.getDateFromString()?.getStringFromDate() ?? "-"))]
        
        return [SectionItem<DetailsSectionType, DetailsItemType, ItemDetails>(type: .site, items: rows, headerTitle: R.string.localizable.my_info())]
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
