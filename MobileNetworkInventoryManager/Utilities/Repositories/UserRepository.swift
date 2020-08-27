//
//  UserRepository.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 17/08/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation
import RxSwift

public class UserRepositoryImpl: UserRepository, UrlMaker {
    public func login(username: String, password: String) -> Observable<DataWrapper<[Login]>> {
        let observable: Observable<[Login]> = RestManager.getRequest(url: makeUrl(username: username, password: password))
        return observable.mapToDataWrapperAndHandleError()
    }
    
    public func getUserData(userId: Int) -> Observable<DataWrapper<[User]>> {
        let observable: Observable<[User]> = RestManager.getRequest(url: makeUrl(action: .getUserData, userId: userId))
        return observable.mapToDataWrapperAndHandleError()
    }
    
    public func getAllUsers() -> Observable<DataWrapper<[User]>> {
        let observable: Observable<[User]> = RestManager.getRequest(url: makeUrl(action: .getAllUsers, userId: nil))
        return observable.mapToDataWrapperAndHandleError()
    }
}

public protocol UserRepository {
    func login(username: String, password: String) -> Observable<DataWrapper<[Login]>>
    func getUserData(userId: Int) -> Observable<DataWrapper<[User]>>
    func getAllUsers() -> Observable<DataWrapper<[User]>>
}
