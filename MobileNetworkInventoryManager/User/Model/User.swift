//
//  User.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 21/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation

public struct User: Codable {
    let user_id: Int
    let name: String
    let surname: String
    let username: String
    let password: String
    let lat: Double
    let lng: Double
    let recorded: String
}
