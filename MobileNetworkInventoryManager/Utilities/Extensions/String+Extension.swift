//
//  String+Extension.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 17/08/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation

public extension String {
    func getDateFromString() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        guard let date = dateFormatter.date(from: self) else {return nil}
        return date
    }
    
    static let empty = ""
}
