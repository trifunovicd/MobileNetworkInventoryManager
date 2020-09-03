//
//  SiteStatus.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 03/09/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation

public struct SiteStatus: Codable {
    let site_id: Int
    let has_active_task: Int
}
