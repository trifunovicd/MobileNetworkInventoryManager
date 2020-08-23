//
//  NetworkError.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 12/08/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation

public enum NetworkError: Error {
    case noDataAvailable
    case canNotProcessData
    case notConnectedToInternet
}
