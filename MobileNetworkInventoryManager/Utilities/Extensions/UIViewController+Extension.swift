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

public extension UIViewController {
    static var spinner: UIView?
    
    func showSpinner(on view: UIView) {
        let spinnerView = UIView.init(frame: view.bounds)
        spinnerView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        let activityIndicator = UIActivityIndicatorView.init(style: .whiteLarge)
        activityIndicator.startAnimating()
        activityIndicator.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(activityIndicator)
            view.addSubview(spinnerView)
        }
        
        UIViewController.spinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            UIViewController.spinner?.removeFromSuperview()
            UIViewController.spinner = nil
        }
    }
}
