//
//  ParentCoordinatorDelegate.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 21/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation

public protocol ParentCoordinatorDelegate: class {
    func childDidFinish(child: Coordinator)
}
