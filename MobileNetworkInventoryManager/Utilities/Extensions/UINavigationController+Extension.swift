//
//  UINavigationController+Extension.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 17/08/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit

public extension UINavigationController {
    func setupNavigationBar(barTintColor: UIColor, titleTextAttributes: [NSAttributedString.Key : Any], tintColor: UIColor, barStyle: UIBarStyle, isTranslucent: Bool) {
        self.navigationBar.barTintColor = barTintColor
        self.navigationBar.titleTextAttributes = titleTextAttributes
        self.navigationBar.tintColor = tintColor
        self.navigationBar.barStyle = barStyle
        self.navigationBar.isTranslucent = isTranslucent
    }
}
