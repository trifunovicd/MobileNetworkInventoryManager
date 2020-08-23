//
//  Observable+Extension.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 22/08/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation
import RxSwift

public extension Observable {
    func mapToDataWrapperAndHandleError() -> Observable<DataWrapper<Element>> {
        return self.map { (element) -> DataWrapper<Element> in
            return DataWrapper.mapToDataWrapper(data: element, error: nil)
            }.catchError { (error) -> Observable<DataWrapper<Element>> in
                let errorWrapper: DataWrapper<Element> = DataWrapper<Element>.createErrorDataWrapper(error: error)
                let observable: Observable<DataWrapper<Element>> = Observable<DataWrapper<Element>>.just(errorWrapper)
                return observable
        }
    }
}
