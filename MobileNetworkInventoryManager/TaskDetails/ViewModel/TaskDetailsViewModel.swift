//
//  TaskDetailsViewModel.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 06/06/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import MapKit

class TaskDetailsViewModel {
    var taskDetails: TaskDetails!
    var shouldFollowUser: Bool = false
    let viewLoaded = PublishSubject<Void>()
    let closeModal = PublishSubject<Void>()
    let addSiteMarker = PublishSubject<Void>()
    let centerMapView = PublishSubject<CLLocationCoordinate2D>()
    let updateDistance = PublishSubject<CLLocationCoordinate2D>()
    let siteDetailsAction = PublishSubject<Bool>()
    let checkLocationServices = PublishSubject<Void>()
    let setupLocationManager = PublishSubject<Void>()
    let checkLocationAuthorization = PublishSubject<Void>()
    let locationAuthorized = PublishSubject<Void>()
    let locationNotDetermined = PublishSubject<Void>()
    let alertOfLocationOff = PublishSubject<Void>()
    let alertOfLocationDenied = PublishSubject<Void>()
    let alertOfLocationRestricted = PublishSubject<Void>()
}
