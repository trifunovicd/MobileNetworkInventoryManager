//
//  TaskDetails.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 06/06/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation

public struct TaskDetails: Details {
    public var siteId: Int
    public var siteMark: String
    public var siteName: String
    public var siteAddress: String
    public var siteTechnology: String
    public var siteDistance: Double
    public var siteLat: Double
    public var siteLng: Double
    public var siteDirections: String
    public var sitePowerSupply: String
    public var taskId: Int
    public var taskDescription: String
    public var taskCategoryName: String
    public var taskStatusName: String
    public var taskOpeningTime: String
    public var taskClosingTime: String
}
