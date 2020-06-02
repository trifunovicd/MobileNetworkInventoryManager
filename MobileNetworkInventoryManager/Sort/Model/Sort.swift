//
//  Sort.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 01/06/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation

enum SortType {
    case sites
    case tasks
}

enum Order: Int {
    case ascending = 0
    case descending = 1
}

enum SitesSortType: Int {
    case mark = 0
    case name = 1
    case address = 2
    case distance = 3
}

enum TasksSortType: Int {
    //TODO
    case name = 0
}
