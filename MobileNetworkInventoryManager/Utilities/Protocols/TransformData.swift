//
//  TransformData.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 27/08/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation
import CoreLocation

public protocol TransformData {
    
}

extension TransformData {
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
}
