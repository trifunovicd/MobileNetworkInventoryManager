//
//  Details.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 23/08/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation

public protocol Details {
    var siteId: Int { get set }
    var siteMark: String { get set }
    var siteName: String { get set }
    var siteAddress: String { get set }
    var siteTechnology: String { get set }
    var siteDistance: Double { get set }
    var siteLat: Double { get set }
    var siteLng: Double { get set }
    var siteDirections: String { get set }
    var sitePowerSupply: String { get set }
}
