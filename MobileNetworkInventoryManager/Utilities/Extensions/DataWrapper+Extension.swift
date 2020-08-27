//
//  DataWrapper+Extension.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 22/08/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation

public extension DataWrapper {
    static func mapToDataWrapper(data: T?, error: Error?) -> DataWrapper<T> {
        if let error = error {
            return DataWrapper.createErrorDataWrapper(error: error)
        }
        return DataWrapper<T>(data: data, error: nil)
    }
    
    static func createErrorDataWrapper<T>(error: Error)-> DataWrapper<T> {
        let networkError: NetworkError
        if let safeError = error as? NetworkError {
            networkError = safeError
        } else {
            networkError = NetworkError.noDataAvailable
        }
        return DataWrapper<T>(data: nil, error: networkError)
    }
}
