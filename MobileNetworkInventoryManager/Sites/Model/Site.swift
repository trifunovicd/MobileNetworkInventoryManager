//
//  Site.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 27/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation

public struct Site: Codable {
    let site_id: Int
    let mark: String
    let name: String
    let address: String
    let is_2G_available: Int
    let is_3G_available: Int
    let is_4G_available: Int
    let lat: Double
    let lng: Double
    let directions: String
    let power_supply: String
}
