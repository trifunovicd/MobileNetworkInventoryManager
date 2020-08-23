//
//  NSObject+Extension.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 17/08/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation

public extension NSObject {
    func printDeinit() {
        print("deinit:", String(describing: self))
    }
}
