//
//  UIView+Extension.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 17/08/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit

public extension UIView {
    func addSubviews(_ views: UIView...){
        for view in views{
            self.addSubview(view)
        }
    }
}
