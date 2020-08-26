//
//  Sort.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 01/06/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation

public enum SortType {
    case sites
    case tasks
}

public enum Order: Int {
    case ascending = 0
    case descending = 1
}

public enum SitesSortType: Int {
    case mark = 0
    case name = 1
    case address = 2
    case distance = 3
}

public enum TasksSortType: Int {
    case date = 0
    case mark = 1
    case name = 2
    case task = 3
    case distance = 4
}
