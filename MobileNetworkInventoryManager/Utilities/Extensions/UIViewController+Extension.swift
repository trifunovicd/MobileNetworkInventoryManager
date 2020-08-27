//
//  UIViewController+Extension.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 27/08/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit

public extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
