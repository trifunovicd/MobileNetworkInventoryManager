//
//  LoginViewModel.swift
//  MobileNetworkInventoryManager
//
//  Created by Danijel Trifunović on 20/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift

class LoginViewModel {
    weak var loginCoordinatorDelegate: CoordinatorDelegate?
    let loginRequest = PublishSubject<(String, String)>()
    let alertOfError = PublishSubject<Void>()
    let alertOfFailedLogin = PublishSubject<Void>()
    let alertOfMissingData = PublishSubject<Void>()
    
    func initialize() -> Disposable{
        loginRequest
            .asObservable()
            .flatMap(getLoginObservale)
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .success(let userId):
                    if userId == 0 {
                        self?.alertOfFailedLogin.onNext(())
                    }
                    else {
                        self?.setLoggedUser(userId: userId)
                    }
                case .failure(let error):
                    print(error)
                    self?.alertOfError.onNext(())
                }
            })
    }
    
    private func getLoginObservale(username: String, password: String) -> Observable<Result<Int, Error>> {
        let observable: Observable<[Login]> = getRequest(url: makeUrl(username: username, password: password))
        
        return observable.map { (userData) -> Result<Int, Error> in
            
            if !userData.isEmpty {
                let userId = userData[0].user_id
                return Result.success(userId)
            }
            else {
                return Result.success(0)
            }
            
        }.catchError { (error) -> Observable<Result<Int, Error>> in
            let result = Result<Int, Error>.failure(error)
            return Observable.just(result)
        }
        
    }
    
    func handleLogin(username: String, password: String) {
        if username.isEmpty || password.isEmpty {
            alertOfMissingData.onNext(())
        }
        else {
            loginRequest.onNext((username, password))
        }
    }
    
    private func setLoggedUser(userId: Int) {
        let loggedUser = LoggedUser()
        loggedUser.id = userId
        
        do {
            let realm = try Realm()
            
            try realm.write {
                realm.add(loggedUser, update: .modified)
            }
            
            loginCoordinatorDelegate?.viewControllerHasFinished()
        } catch  {
            print(error)
        }
    }
}
