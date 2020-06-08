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
    let userRequest = PublishSubject<Void>()
    let fetchFinished = PublishSubject<Void>()
    let alertOfError = PublishSubject<Void>()
    let refreshAction = PublishSubject<Void>()
    let locationService = LocationService.instance
    
    init() {
        locationService.delegate = self
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
            
            let userPreview = UserPreview(name: user.name, surname: user.surname, username: user.username, lat: user.lat, lng: user.lng, recorded: user.recorded)
            
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
}


extension UserViewModel: CustomLocationManagerDelegate {
    func customLocationManager(didUpdate locations: [CLLocation]) {
//        guard let location = locations.last else { return }
//        updateDistance.onNext(location.coordinate)
//
//        if shouldFollowUser {
//            centerMapView.onNext(location.coordinate)
//        }
    }
}
