//
//  Task.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 06/06/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation

public struct Task: Codable {
    let task_id: Int
    let site_id: Int
    let site_mark: String
    let site_name: String
    let site_address: String
    let is_2G_available: Int
    let is_3G_available: Int
    let is_4G_available: Int
    let site_lat: Double
    let site_lng: Double
    let site_directions: String
    let site_power_supply: String
    let task_description: String
    let task_category: Int
    let task_category_name: String
    let task_status: Int
    let task_status_name: String
    let task_opening_time: String
    let task_closing_time: String?
}
