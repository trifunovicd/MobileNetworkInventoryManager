//
//  SortDelegate.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 31/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation

public protocol SortDelegate: class {
    func sortBy(value: Int, order: Int)
}
