//
//  ModalDelegate.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 05/09/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation

public protocol ModalDelegate: class {
    func getTasks()
    func dismissModal()
}
