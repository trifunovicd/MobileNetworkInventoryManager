//
//  SiteSortSettings.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 02/06/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation
import RealmSwift

class SiteSortSettings: Object {
    @objc dynamic var id: String = "siteSort"
    @objc dynamic var value: SitesSortType.RawValue = 0
    @objc dynamic var order: Order.RawValue = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
