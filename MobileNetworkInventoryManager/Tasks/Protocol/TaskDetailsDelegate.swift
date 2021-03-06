//
//  TaskDetailsDelegate.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 06/06/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation

public protocol TaskDetailsDelegate: class {
    func openTaskDetails(taskDetails: TaskDetails)
}
