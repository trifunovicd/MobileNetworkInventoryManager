//
//  Enums.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 17/08/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation

public enum SitesSelectedScope: Int {
    case name = 0
    case address = 1
    case tech = 2
    case mark = 3
}

public enum TasksSelectedScope: Int {
    case name = 0
    case task = 1
    case date = 2
    case mark = 3
}

public enum MapType: Int {
    case sites = 0
    case users = 1
}

public enum Action {
    case getAllSites
    case getAllUsers
    case getTasksForUser
    case getUserData
    case getTaskStatus
    case getSiteStatus
}

public enum Status: Int {
    case all = 0
    case completed = 1
    case notCompleted = 2
    
    func getTitle() -> String {
        switch self {
        case .all:
            return R.string.localizable.all_tasks()
        case .completed:
            return R.string.localizable.completed()
        case .notCompleted:
            return R.string.localizable.not_completed()
        }
    }
}
