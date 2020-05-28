//
//  Site.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 27/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation

struct Site: Codable {
    let site_id: Int
    let interna_oznaka: String
    let naziv: String
    let adresa: String
    let is_2G_available: Int
    let is_3G_available: Int
    let is_4G_available: Int
    let lat: Double
    let lng: Double
    let opis_puta: String
    let vrsta_napajanja: String
}
