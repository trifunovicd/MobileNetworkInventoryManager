//
//  CustomLocationManagerDelegate.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 08/06/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation
import CoreLocation

protocol CustomLocationManagerDelegate: AnyObject {
    func customLocationManager(didUpdate locations: [CLLocation])
}
