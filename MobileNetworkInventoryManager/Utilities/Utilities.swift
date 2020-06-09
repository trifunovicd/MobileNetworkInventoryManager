//
//  Utilities.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 20/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

//MARK: Enums
enum SitesSelectedScope: Int {
    case name = 0
    case address = 1
    case tech = 2
    case mark = 3
}

enum TasksSelectedScope: Int {
    case name = 0
    case task = 1
    case date = 2
    case mark = 3
}

enum MapType: Int {
    case sites = 0
    case users = 1
}

//MARK: Extensions
extension UIView {
    func addSubviews(views: [UIView]) {
        for view in views {
            self.addSubview(view)
        }
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}

extension UINavigationController {
    func setupNavigationBar(barTintColor: UIColor, titleTextAttributes: [NSAttributedString.Key : Any], tintColor: UIColor, barStyle: UIBarStyle, isTranslucent: Bool) {
        self.navigationBar.barTintColor = barTintColor
        self.navigationBar.titleTextAttributes = titleTextAttributes
        self.navigationBar.tintColor = tintColor
        self.navigationBar.barStyle = barStyle
        self.navigationBar.isTranslucent = isTranslucent
    }
}

extension Double {
    func getDistanceString() -> String {
        if self < 1000 {
            let rounded = String(format: "%.f", self)
            return R.string.localizable.distance_in_m(rounded)
        }
        else {
            let km = self / 1000
            let rounded = String(format: "%.2f", km)
            return R.string.localizable.distance_in_km(rounded)
        }
    }
}

extension String {
    func getDateFromString() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        guard let date = dateFormatter.date(from: self) else {return nil}
        return date
    }
}

extension Date {
    func getStringFromDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        let sDate = dateFormatter.string(from: self)
        return sDate
    }
    
    func getMSSQLVariant() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "hr_HR")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let sDate = dateFormatter.string(from: self)
        return sDate
    }
}

extension MKMapView {
    func fitMapViewToAnnotaionList() -> Void {
        let mapEdgePadding = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        var zoomRect: MKMapRect = MKMapRect.null

        for index in 0..<self.annotations.count {
            let annotation = self.annotations[index]
            let aPoint:MKMapPoint = MKMapPoint(annotation.coordinate)
            let rect:MKMapRect = MKMapRect(x: aPoint.x, y: aPoint.y, width: 0.1, height: 0.1)

            if zoomRect.isNull {
                zoomRect = rect
            } else {
                zoomRect = zoomRect.union(rect)
            }
        }
        self.setVisibleMapRect(zoomRect, edgePadding: mapEdgePadding, animated: true)
    }
}

//MARK: Public Functions
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
