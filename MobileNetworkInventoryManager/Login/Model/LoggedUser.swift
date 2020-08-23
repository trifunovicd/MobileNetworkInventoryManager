//
//  LoggedUser.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 02/06/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation
import RealmSwift

public class LoggedUser: Object {
    @objc dynamic var user: String = "loggedUser"
    @objc dynamic var id: Int = 0
    
    public override static func primaryKey() -> String? {
        return "user"
    }
}
