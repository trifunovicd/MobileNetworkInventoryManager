//
//  RowItem.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 23/08/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation

public struct RowItem <ItemType, DataType> {
    public var type: ItemType
    public var data: DataType
}
