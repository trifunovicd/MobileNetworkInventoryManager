//
//  LoginViewModel.swift
//  MobileNetworkInventoryManager
//
//  Created by Internship on 20/05/2020.
//  Copyright © 2020 Danijel Trifunović. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift

class LoginViewModel {
    weak var loginCoordinatorDelegate: ViewControllerDelegate?
    let loginRequest = PublishSubject<(String, String)>()
    let loginSuccessful = PublishSubject<Void>()
    let alertOfError = PublishSubject<Void>()
    let alertOfFailedLogin = PublishSubject<Void>()
    let alertOfMissingData = PublishSubject<Void>()
    
    func initialize() -> Disposable{
        loginRequest
            .asObservable()
            .flatMap(getUserObservale)
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .success(let userId):
                    if userId == 0 {
                        self?.alertOfFailedLogin.onNext(())
                    }
                    else {
                        self?.saveLoggedUser(userId: userId)
                    }
                case .failure(let error):
                    print(error)
                    self?.alertOfError.onNext(())
                }
            })
    }
    
    private func getUserObservale(username: String, password: String) -> Observable<Result<Int, Error>> {
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
    
    private func saveLoggedUser(userId: Int) {
        let loggedUser = LoggedUser()
        loggedUser.id = userId
        
        do {
            let realm = try Realm()
            
            try realm.write {
                realm.add(loggedUser, update: .modified)
            }
            
            loginSuccessful.onNext(())
        } catch  {
            print(error)
        }
    }
}
