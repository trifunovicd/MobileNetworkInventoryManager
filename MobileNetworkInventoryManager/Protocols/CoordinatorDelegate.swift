//
//  CoordinatorDelegate.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 21/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation

protocol CoordinatorDelegate: AnyObject {
    func childDidFinish(child: Coordinator)
}
