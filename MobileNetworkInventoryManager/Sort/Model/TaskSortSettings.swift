//
//  TaskSortSettings.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 06/06/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation
import RealmSwift

class TaskSortSettings: Object {
    @objc dynamic var id: String = "taskSort"
    @objc dynamic var value: TasksSortType.RawValue = 0
    @objc dynamic var order: Order.RawValue = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
