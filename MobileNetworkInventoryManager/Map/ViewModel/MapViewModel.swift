//
//  MapViewModel.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 20/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation

class MapViewModel {
    weak var mapCoordinatorDelegate: MapCoordinator?
    var userId: Int!
    var loggedUser: User!
    var segmentedIndex: Int = 0
    var shouldFollowUser: Bool = false
    var sites: [Site] = []
    var usersPreviews: [UserPreview] = []
    let itemsRequest = PublishSubject<Void>()
    let alertOfError = PublishSubject<Void>()
    let addMarker = PublishSubject<Any>()
    let removeMarkers = PublishSubject<Void>()
    let centerMapView = PublishSubject<CLLocationCoordinate2D>()
    let fitMapView = PublishSubject<Void>()
    let locationService = LocationService.instance
    
    init() {
        locationService.delegate = self
    }
    
    func initialize() -> Disposable{
        itemsRequest
            .asObservable()
            .flatMap(getItemsObservale)
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .success(let data):
                    self?.sites = data.0
                    self?.usersPreviews = data.1
                    self?.loggedUser = data.2
                    self?.handleSegmentedOptionChange(index: self!.segmentedIndex)
                case .failure(let error):
                    print(error)
                    self?.alertOfError.onNext(())
                }
            })
    }
    
    private func getItemsObservale() -> Observable<Result<([Site], [UserPreview], User), Error>> {
        let sitesObservable: Observable<[Site]> = getRequest(url: makeUrl(action: .getAllSites, userId: nil))
        let usersObservable: Observable<[User]> = getRequest(url: makeUrl(action: .getAllUsers, userId: nil))
        
        var uPreviews: [UserPreview] = []
        
        return Observable.combineLatest(sitesObservable, usersObservable, resultSelector: { [unowned self] sites, users in
            var currentUser: User!
            
            for user in users {
                if user.user_id == self.userId {
                    currentUser = user
                    break
                }
            }
            
            for user in users {
                if user.user_id != self.userId {
                    let distance = getDistance(userLocation: (currentUser.lat, currentUser.lng), siteLocation: (user.lat, user.lng))
                    let userPreview = UserPreview(name: user.name, surname: user.surname, username: user.username, lat: user.lat, lng: user.lng, recorded: user.recorded, distance: distance.getDistanceString())
                    uPreviews.append(userPreview)
                }
            }
            
            return (sites, uPreviews, currentUser)
            
        }).map { (data) -> Result<([Site], [UserPreview], User), Error> in
            return Result.success(data)
            
        }.catchError { error -> Observable<Result<([Site], [UserPreview], User), Error>> in
            let result = Result<([Site], [UserPreview], User), Error>.failure(error)
            return Observable.just(result)
        }
    }
    
    func showSiteDetails(siteId: Int) {
        for site in sites {
            if site.site_id == siteId {
                let technology = getTechnology(is2GAvailable: site.is_2G_available, is3GAvailable: site.is_3G_available, is4GAvailable: site.is_4G_available)
                let distance = getDistance(userLocation: (loggedUser.lat, loggedUser.lng), siteLocation: (site.lat, site.lng))
                let siteDetails = SiteDetails(siteId: site.site_id, mark: site.mark, name: site.name, address: site.address, technology: technology, distance: distance, lat: site.lat, lng: site.lng, directions: site.directions, powerSupply: site.power_supply)

                mapCoordinatorDelegate?.openSiteDetails(siteDetails: siteDetails)
                break
            }
        }
    }
    
    func handleSegmentedOptionChange(index: Int) {
        segmentedIndex = index
        shouldFollowUser = false
        
        guard let mapType = MapType(rawValue: index) else { return }
        
        removeMarkers.onNext(())
        
        switch mapType {
        case .sites:
            for site in sites {
                addMarker.onNext(site)
            }
        case .users:
            for user in usersPreviews {
                addMarker.onNext(user)
            }
        }
        
        fitMapView.onNext(())
    }
}


extension MapViewModel: CustomLocationManagerDelegate {
    func customLocationManager(didUpdate locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        if shouldFollowUser {
            centerMapView.onNext(location.coordinate)
        }
    }
}
