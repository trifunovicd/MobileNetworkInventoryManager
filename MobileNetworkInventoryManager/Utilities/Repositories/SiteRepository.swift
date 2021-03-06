//
//  SiteRepository.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 22/08/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation
import RxSwift

public class SiteRepositoryImpl: SiteRepository, UrlMaker {
    public func getSites() -> Observable<DataWrapper<[Site]>> {
        let observable: Observable<[Site]> = RestManager.getRequest(url: makeUrl(action: .getAllSites, userId: nil))
        return observable.mapToDataWrapperAndHandleError()
    }
    
    public func getSitesStatus() -> Observable<DataWrapper<[SiteStatus]>> {
        let observable: Observable<[SiteStatus]> = RestManager.getRequest(url: makeUrl(action: .getSiteStatus, userId: nil))
        return observable.mapToDataWrapperAndHandleError()
    }
}

public protocol SiteRepository {
    func getSites() -> Observable<DataWrapper<[Site]>>
    func getSitesStatus() -> Observable<DataWrapper<[SiteStatus]>>
}
