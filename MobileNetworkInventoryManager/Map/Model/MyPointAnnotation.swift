//
//  MyPointAnnotation.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 09/06/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation
import MapKit

class MyPointAnnotation : MKPointAnnotation {
    var siteIdentifier: Int?
    var recorded: String?
    var distance: String?
    var showDistance: Bool?
}
