//
//  Utilities.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 20/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit

enum SelectedScope: Int {
    case name = 0
    case address = 1
    case tech = 2
    case mark = 3
}

extension UIView {
    func addSubviews(views: [UIView]) {
        for view in views {
            self.addSubview(view)
        }
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}

extension UINavigationController {
    func setupNavigationBar(barTintColor: UIColor, titleTextAttributes: [NSAttributedString.Key : Any], tintColor: UIColor, barStyle: UIBarStyle, isTranslucent: Bool) {
        self.navigationBar.barTintColor = barTintColor
        self.navigationBar.titleTextAttributes = titleTextAttributes
        self.navigationBar.tintColor = tintColor
        self.navigationBar.barStyle = barStyle
        self.navigationBar.isTranslucent = isTranslucent
    }
}

func getAlert(title: String, message: String, actionTitle: String) -> UIAlertController {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: actionTitle, style: .cancel, handler: nil))

    return alert
}
