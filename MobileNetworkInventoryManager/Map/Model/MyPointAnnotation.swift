//
//  MyPointAnnotation.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 09/06/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation
import MapKit

public class MyPointAnnotation : MKPointAnnotation {
    var siteIdentifier: Int?
    var siteHasActiveTask: Bool?
    var recorded: String?
    var distance: String?
    var showDistance: Bool?
}
