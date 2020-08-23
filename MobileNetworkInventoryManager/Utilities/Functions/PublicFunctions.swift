//
//  PublicFunctions.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 17/08/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit
import CoreLocation

func makeUrl(username: String, password: String) -> String {
    let url = Urls.baseUrlGet.rawValue + R.string.localizable.check_if_user_exists(username, password)
    guard let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return url }
    return urlString
}

func makeUrl(action: Action, userId: Int?) -> String {
    var url = Urls.baseUrlGet.rawValue
    
    switch action {
    case .getAllSites:
        url = url + R.string.localizable.get_all_sites()
    case .getAllUsers:
        url = url + R.string.localizable.get_all_users()
    case .getTasksForUser:
        guard let userId = userId else { break }
        url = url + R.string.localizable.get_tasks_for_user(userId)
    case .getUserData:
        guard let userId = userId else { break }
        url = url + R.string.localizable.get_user_data(userId)
    case .getTaskStatus:
        url = url + R.string.localizable.get_task_status()
    }
    
    return url
}

func getAlert(title: String, message: String, actionTitle: String) -> UIAlertController {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: actionTitle, style: .cancel, handler: nil))

    return alert
}

func getDistance(userLocation: (lat: Double, lng: Double), siteLocation: (lat: Double, lng: Double)) -> Double {
    
    let userLocation = CLLocation(latitude: userLocation.lat, longitude: userLocation.lng)
    let siteLocation = CLLocation(latitude: siteLocation.lat, longitude: siteLocation.lng)

    let distance = userLocation.distance(from: siteLocation)
    return distance
}

func getTechnology(is2GAvailable: Int, is3GAvailable: Int, is4GAvailable: Int) -> String {
    var technology: String = ""
    
    if is2GAvailable == 1 {
        technology = technology + " 2G"
    }
    if is3GAvailable == 1 {
        technology = technology + " 3G"
    }
    if is4GAvailable == 1 {
        technology = technology + " 4G"
    }
    
    technology = String(technology.dropFirst())
    technology = technology.replacingOccurrences(of: " ", with: ", ")
    return technology
}

func topMostViewController() -> UIViewController? {
    var topViewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
    while ((topViewController?.presentedViewController) != nil) {
        topViewController = topViewController?.presentedViewController
    }
    return topViewController
}
