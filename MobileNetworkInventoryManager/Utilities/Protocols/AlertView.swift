//
//  AlertView.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 27/08/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import UIKit
import RxSwift

public protocol AlertView {
    
}

extension AlertView {
    func getAlert(title: String, message: String, actionTitle: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .cancel, handler: nil))

        return alert
    }
    
    func getActionAlert<Element>(title: String, message: String, actionTitle: String, cancelTitle: String, subject: Observable<Element>, event: Element) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action) in
            if let publishSubject = subject as? PublishSubject<Element> {
                publishSubject.onNext(event)
            } else if let replaySubject = subject as? ReplaySubject<Element> {
                replaySubject.onNext(event)
            }
        }))
        return alert
    }
}
