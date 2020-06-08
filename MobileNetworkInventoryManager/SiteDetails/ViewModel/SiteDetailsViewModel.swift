//
//  SiteDetailsViewModel.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 04/06/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation

class SiteDetailsViewModel {
    var siteDetails: SiteDetails!
    var shouldFollowUser: Bool = false
    let viewLoaded = PublishSubject<Void>()
    let closeModal = PublishSubject<Void>()
    let addSiteMarker = PublishSubject<Void>()
    let centerMapView = PublishSubject<CLLocationCoordinate2D>()
    let updateDistance = PublishSubject<CLLocationCoordinate2D>()
    let locationService = LocationService.instance
    
    init() {
        locationService.delegate = self
    }
}


extension SiteDetailsViewModel: CustomLocationManagerDelegate {
    func customLocationManager(didUpdate locations: [CLLocation]) {
        guard let location = locations.last else { return }
        updateDistance.onNext(location.coordinate)
        
        if shouldFollowUser {
            centerMapView.onNext(location.coordinate)
        }
    }
}
