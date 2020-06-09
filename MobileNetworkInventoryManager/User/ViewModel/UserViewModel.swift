//
//  UserViewModel.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 20/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation
import RealmSwift

class UserViewModel {
    weak var userCoordinatorDelegate: UserCoordinator?
    var userId: Int!
    var userData: UserPreview!
    var shouldFollowUser: Bool = false
    let userRequest = PublishSubject<Void>()
    let fetchFinished = PublishSubject<Void>()
    let alertOfError = PublishSubject<Void>()
    let addUserMarker = PublishSubject<Void>()
    let centerMapView = PublishSubject<CLLocationCoordinate2D>()
    let locationService = LocationService.instance
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(listenForLocationUpdates(_:)), name: NSNotification.Name(rawValue: R.string.localizable.notification_name()), object: locationService)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: R.string.localizable.notification_name()), object: locationService)
    }
    
    func initialize() -> Disposable{
        userRequest
            .asObservable()
            .flatMap(getUserObservale)
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .success(let data):
                    self?.userData = data
                    self?.fetchFinished.onNext(())
                case .failure(let error):
                    print(error)
                    self?.alertOfError.onNext(())
                }
            })
    }
    
    
    private func getUserObservale() -> Observable<Result<UserPreview, Error>> {
        let observable: Observable<[User]> = getRequest(url: makeUrl(action: .getUserData, userId: userId))
        
        return observable.map { (userData) -> Result<UserPreview, Error> in
            let user = userData[0]
            
            let userPreview = UserPreview(name: user.name, surname: user.surname, username: user.username, lat: user.lat, lng: user.lng, recorded: user.recorded, distance: nil)
            
            return Result.success(userPreview)
            
        }.catchError { (error) -> Observable<Result<UserPreview, Error>> in
            let result = Result<UserPreview, Error>.failure(error)
            return Observable.just(result)
        }
        
    }
    
    
    func logout() {
        do {
            let realm = try Realm()
            
            try realm.write {
                realm.deleteAll()
            }
            locationService.stop()
            userCoordinatorDelegate?.viewControllerHasFinished()
        } catch  {
            print(error)
        }
    }
    
    
    @objc private func listenForLocationUpdates(_ notification: NSNotification) {
        guard let dict = notification.userInfo as NSDictionary?, let locations = dict[R.string.localizable.notification_info()] as? [CLLocation], let location = locations.last else { return }
        if shouldFollowUser {
            centerMapView.onNext(location.coordinate)
        }
    }
}
