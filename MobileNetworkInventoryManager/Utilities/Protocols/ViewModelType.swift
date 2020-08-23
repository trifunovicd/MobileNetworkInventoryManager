//
//  ViewModelType.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 12/08/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation
public protocol ViewModelType {
    associatedtype Dependecies
    associatedtype Input
    associatedtype Output

    func transform(input: Input) -> Output
}
