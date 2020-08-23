//
//  Date+Extension.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 17/08/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation

public extension Date {
    func getStringFromDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        let sDate = dateFormatter.string(from: self)
        return sDate
    }
    
    func getMSSQLVariant() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "hr_HR")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let sDate = dateFormatter.string(from: self)
        return sDate
    }
}
