//
//  SortViewModel.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 01/06/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

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
    let showView = PublishSubject<Void>()
    let hideView = PublishSubject<Void>()
    
    init(frame: CGRect, delegate: SortDelegate, sortType: SortType) {
        self.frame = frame
        self.delegate = delegate
        self.sortType = sortType
        createItems()
    }
    
    private func createItems() {
        switch sortType {
        case .sites:
            itemsArray = [R.string.localizable.scope_mark(), R.string.localizable.scope_name(), R.string.localizable.scope_address(), R.string.localizable.distance()]
        case .tasks:
            itemsArray = [R.string.localizable.scope_date(), R.string.localizable.scope_mark(), R.string.localizable.scope_name(), R.string.localizable.scope_task(), R.string.localizable.distance()]
        }
    }
}
