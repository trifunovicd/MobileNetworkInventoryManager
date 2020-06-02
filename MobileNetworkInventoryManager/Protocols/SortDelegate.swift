//
//  SortDelegate.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 31/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation

protocol SortDelegate: AnyObject {
    func sortBy(value: Int, order: Order)
}
