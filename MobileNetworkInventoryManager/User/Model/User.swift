//
//  User.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 21/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation

struct User: Codable {
    let user_id: Int
    let ime: String
    let prezime: String
    let korisnicko_ime: String
    let lozinka: String
    let lat: Double
    let lng: Double
    let vrijeme: Date
}
