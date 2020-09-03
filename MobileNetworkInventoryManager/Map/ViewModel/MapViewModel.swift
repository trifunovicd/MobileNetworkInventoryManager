//
//  MapViewModel.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 20/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation

public class MapViewModel: ViewModelType, TransformData {
    
    public struct Input {
        let loadDataSubject: ReplaySubject<()>
        let siteDetailsSubject: PublishSubject<Int>
    }
    
    public struct Output {
        var disposables: [Disposable]
        let alertOfError: PublishSubject<LoadError>
        let addMarker: PublishSubject<Any>
        let removeMarkers: PublishSubject<()>
        let centerMapView: PublishSubject<CLLocationCoordinate2D>
        let fitMapView: PublishSubject<()>
    }
    
    public struct Dependecies {
        let subscribeScheduler: SchedulerType
        weak var coordinatorDelegate: CoordinatorDelegate?
        weak var mapCoordinatorDelegate: SiteDetailsDelegate?
        let userRepository: UserRepository
        let siteRepository: SiteRepository
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
    
    var loggedUser: User!
    var sites: [Site] = []
    var sitesStatus: [SiteStatus] = []
    var usersPreviews: [UserPreview] = []
    var shouldFollowUser: Bool = false
    var segmentedIndex: Int = 0
    
    public func transform(input: Input) -> Output {
        var disposables = [Disposable]()
        disposables.append(initializeLoadDataObservable(for: input.loadDataSubject))
        disposables.append(initializeSiteDetailsObservable(for: input.siteDetailsSubject))
        let output = Output(disposables: disposables, alertOfError: PublishSubject(), addMarker: PublishSubject(), removeMarkers: PublishSubject(), centerMapView: PublishSubject(), fitMapView: PublishSubject())
        
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
}

private extension MapViewModel {
    func initializeLoadDataObservable(for subject: ReplaySubject<()>) -> Disposable {
        return subject.flatMap {[unowned self] (_) -> Observable<DataWrapper<([Site], [SiteStatus], [UserPreview], User)>> in
            return self.combineObservables(sitesObservable: self.dependecies.siteRepository.getSites(), sitesStatusObservable: self.dependecies.siteRepository.getSitesStatus(), usersObservable: self.dependecies.userRepository.getAllUsers())
        }
        .observeOn(MainScheduler.instance)
        .subscribeOn(dependecies.subscribeScheduler)
        .subscribe(onNext: { [unowned self] (dataWrapper) in
            guard let safeData = dataWrapper.data else {
                self.handleError(error: dataWrapper.error)
                return
            }
            self.sites = safeData.0
            self.sitesStatus = safeData.1
            self.usersPreviews = safeData.2
            self.loggedUser = safeData.3
            self.handleSegmentedOptionChange(index: self.segmentedIndex)
        })
    }
    
    func combineObservables(sitesObservable: Observable<DataWrapper<[Site]>>, sitesStatusObservable: Observable<DataWrapper<[SiteStatus]>>, usersObservable: Observable<DataWrapper<[User]>>) -> Observable<DataWrapper<([Site], [SiteStatus], [UserPreview], User)>> {
            
        return Observable<DataWrapper<([Site], [SiteStatus], [UserPreview], User)>>.combineLatest(sitesObservable, sitesStatusObservable, usersObservable, resultSelector: { sitesWrapper, sitesStatusWrapper, usersWrapper in
            var currentUser: User!
            var uPreviews: [UserPreview] = []
            
            if let sites = sitesWrapper.data, let sitesStatus = sitesStatusWrapper.data, let users = usersWrapper.data {
                for user in users {
                    if user.user_id == self.dependecies.userId {
                        currentUser = user
                    } else {
                        let distance = self.getDistance(userLocation: (currentUser.lat, currentUser.lng), siteLocation: (user.lat, user.lng))
                        let userPreview = UserPreview(name: user.name, surname: user.surname, username: user.username, lat: user.lat, lng: user.lng, recorded: user.recorded, distance: distance.getDistanceString())
                        uPreviews.append(userPreview)
                    }
                }
                return DataWrapper(data: (sites, sitesStatus, uPreviews, currentUser), error: nil)
            }
            guard let sitesNetError = sitesWrapper.error as? NetworkError,
                let sitesStatusNetError = sitesStatusWrapper.error as? NetworkError,
                let usersNetError = usersWrapper.error as? NetworkError,
                sitesNetError == .notConnectedToInternet || sitesStatusNetError == .notConnectedToInternet || usersNetError == .notConnectedToInternet else {
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

private extension MapViewModel {
    func initializeSiteDetailsObservable(for subject: PublishSubject<Int>) -> Disposable{
        return subject
        .observeOn(MainScheduler.instance)
        .subscribeOn(dependecies.subscribeScheduler)
        .subscribe(onNext: {[unowned self] (siteId) in
            self.showSiteDetails(siteId: siteId)
        })
    }
    
    func showSiteDetails(siteId: Int) {
        for site in sites {
            if site.site_id == siteId {
                let technology = getTechnology(is2GAvailable: site.is_2G_available, is3GAvailable: site.is_3G_available, is4GAvailable: site.is_4G_available)
                let distance = getDistance(userLocation: (loggedUser.lat, loggedUser.lng), siteLocation: (site.lat, site.lng))
                let siteDetails = SiteDetails(siteId: site.site_id, siteMark: site.mark, siteName: site.name, siteAddress: site.address, siteTechnology: technology, siteDistance: distance, siteLat: site.lat, siteLng: site.lng, siteDirections: site.directions, sitePowerSupply: site.power_supply)

                    dependecies.mapCoordinatorDelegate?.openSiteDetails(siteDetails: siteDetails)
                break
            }
        }
    }
}

public extension MapViewModel {
    func handleSegmentedOptionChange(index: Int) {
        segmentedIndex = index
        shouldFollowUser = false
        
        guard let mapType = MapType(rawValue: index) else { return }
        
        output.removeMarkers.onNext(())
        
        switch mapType {
        case .sites:
            for site in sites {
                for siteStatus in sitesStatus {
                    if site.site_id == siteStatus.site_id {
                        output.addMarker.onNext((site, siteStatus.has_active_task))
                    }
                }
            }
        case .users:
            for user in usersPreviews {
                output.addMarker.onNext(user)
            }
        }
        
        output.fitMapView.onNext(())
    }
}
