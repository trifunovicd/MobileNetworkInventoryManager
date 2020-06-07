//
//  LocationService.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 07/06/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit
import CoreLocation

class LocationService: NSObject {
    
    static let instance = LocationService()
    private let locationManager = CLLocationManager()
    private var latestLocation: CLLocationCoordinate2D!
    private var shouldUpdate: Bool = true
    private var initialUpdate: Bool = true
    var userId: Int!
    var controller: UITabBarController!
    
    func start() {
        checkLocationServices()
    }
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        }
        else {
            let alert = getAlert(title: R.string.localizable.location_off_alert_title(), message: R.string.localizable.location_off_alert_message(), actionTitle: R.string.localizable.alert_ok_action())
            controller.selectedViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    private func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            startTimer()
        case .denied:
            let alert = getAlert(title: R.string.localizable.location_denied_alert_title(), message: R.string.localizable.location_denied_alert_message(), actionTitle: R.string.localizable.alert_ok_action())
            controller.selectedViewController?.present(alert, animated: true, completion: nil)
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            let alert = getAlert(title: R.string.localizable.location_restricted_alert_title(), message: R.string.localizable.location_restricted_alert_message(), actionTitle: R.string.localizable.alert_ok_action())
            controller.selectedViewController?.present(alert, animated: true, completion: nil)
        case .authorizedAlways:
            break
        @unknown default:
            break
        }
    }
    
    private func initialLocationUpdate() {
        if initialUpdate {
            makeRequest()
            initialUpdate = false
        }
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
            if self.shouldUpdate {
                self.makeRequest()
                self.shouldUpdate = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.shouldUpdate = true
            }
        }
    }
    
    private func makeRequest() {
        guard let location = self.latestLocation else { return }
        let postString = R.string.localizable.update_user_location(self.userId, location.latitude, location.longitude, Date().getMSSQLVariant())
        postRequest(url: Urls.baseUrlPost.rawValue, postString: postString)
    }
}


extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        latestLocation = location.coordinate
        initialLocationUpdate()
        print(location.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}
