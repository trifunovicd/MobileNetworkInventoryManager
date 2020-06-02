//
//  SortViewModel.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 01/06/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit

class SortViewModel {
    let window = UIApplication.shared.keyWindow
    let screenSize = UIScreen.main.bounds.size
    var height: CGFloat = 260
    var itemsArray: [String]!
    let orderArray = [R.string.localizable.ascending(), R.string.localizable.descending()]
    let frame: CGRect
    let delegate: SortDelegate
    let sortType: SortType
    var settings: (value: Int, order: Int)!
    
    init(frame: CGRect, delegate: SortDelegate, sortType: SortType) {
        self.frame = frame
        self.delegate = delegate
        self.sortType = sortType
        createArray()
    }
    
    private func createArray() {
        switch sortType {
        case .sites:
            itemsArray = [R.string.localizable.mark(), R.string.localizable.name(), R.string.localizable.address(), R.string.localizable.distance()]
        case .tasks:
            itemsArray = [""] //TODO!!!!!
        }
    }
}
