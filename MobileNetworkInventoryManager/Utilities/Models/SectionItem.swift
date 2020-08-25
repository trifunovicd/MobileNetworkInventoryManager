//
//  SectionItem.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 23/08/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation

public struct SectionItem<SectionType, ItemType, ItemData> {
    let type: SectionType
    let items: [RowItem<ItemType, ItemData>]
    let headerTitle: String
}
