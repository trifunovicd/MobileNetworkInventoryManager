//
//  TaskPreview.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 06/06/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation

public struct TaskPreview {
    let taskId: Int
    let taskCategoryName: String
    let siteMark: String
    let siteName: String
    let taskOpeningTime: Date?
    let distance: Double
    let taskStatus: Int
}
