//
//  DataWrapper.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 12/08/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation

public struct DataWrapper<T> {
    public let data: T?
    public let error: Error?

    public init (data: T?, error: Error?){
        self.data = data
        self.error = error
    }
}
