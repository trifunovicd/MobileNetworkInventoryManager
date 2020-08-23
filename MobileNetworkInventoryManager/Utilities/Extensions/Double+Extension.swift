//
//  Double+Extension.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 17/08/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation

public extension Double {
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
